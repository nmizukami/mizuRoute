MODULE write_simoutput

! Moudle wide external modules
USE nrtype
USE public_var
USE public_var,only: routOpt                ! routing scheme options  0-> both, 1->IRF, 2->KWT, otherwise error
USE public_var,only: doesBasinRoute         ! basin routing options   0-> no, 1->IRF, otherwise error
USE public_var,only: doesAccumRunoff        ! option to delayed runoff accumulation over all the upstream reaches. 0->no, 1->yes
USE public_var,only: kinematicWave          ! kinematic wave
USE public_var,only: impulseResponseFunc    ! impulse response function
USE public_var,only: allRoutingMethods      ! all routing methods
USE io_netcdf, only: ncd_int
USE io_netcdf, only: ncd_float, ncd_double
USE io_netcdf, only: ncd_unlimited
USE io_netcdf, only: def_nc                 ! define netcdf
USE io_netcdf, only: def_var                ! define netcdf variable
USE io_netcdf, only: def_dim                ! define netcdf dimension
USE io_netcdf, only: put_global_attr        ! write global attributes
USE io_netcdf, only: end_def                ! end defining netcdf
USE io_netcdf, only: close_nc               ! close netcdf
USE io_netcdf, only: write_nc               ! write a variable to the NetCDF file

implicit none

! The following variables used only in this module
character(len=strLen),save        :: fileout          ! name of the output file
integer(i4b),         save        :: jTime            ! time step in output netCDF

private

public::prep_output
public::output

CONTAINS

 ! *********************************************************************
 ! public subroutine: define routing output NetCDF file
 ! *********************************************************************
 SUBROUTINE output(ierr, message)    ! out:   error control
  !Dependent modules
  USE var_lookup, ONLY: ixRFLX
  USE globalData, ONLY: meta_rflx
  USE globalData, ONLY: nHRU, nRch          ! number of ensembles, HRUs and river reaches
  USE globalData, ONLY: RCHFLX              ! Reach fluxes (ensembles, space [reaches])
  USE globalData, ONLY: runoff_data         ! runoff data for one time step for LSM HRUs and River network HRUs

  implicit none

  ! input variables: none
  ! output variables
  integer(i4b), intent(out)       :: ierr             ! error code
  character(*), intent(out)       :: message          ! error message
  ! local variables
  integer(i4b)                    :: iens             ! temporal
  character(len=strLen)           :: cmessage         ! error message of downwind routine

  ! initialize error control
  ierr=0; message='output/'

  iens = 1

  ! write time -- note time is just carried across from the input
  call write_nc(trim(fileout), 'time', (/runoff_data%time/), (/jTime/), (/1/), ierr, cmessage)
  if(ierr/=0)then; message=trim(message)//trim(cmessage); return; endif

  if (meta_rflx(ixRFLX%basRunoff)%varFile) then
   ! write the basin runoff at HRU (m/s)
   call write_nc(trim(fileout), 'basRunoff', runoff_data%basinRunoff, (/1,jTime/), (/nHRU,1/), ierr, cmessage)
   if(ierr/=0)then; message=trim(message)//trim(cmessage); return; endif
  endif

  if (meta_rflx(ixRFLX%instRunoff)%varFile) then
   ! write instataneous local runoff in each stream segment (m3/s)
   call write_nc(trim(fileout), 'instRunoff', RCHFLX(iens,:)%BASIN_QI, (/1,jTime/), (/nRch,1/), ierr, cmessage)
   if(ierr/=0)then; message=trim(message)//trim(cmessage); return; endif
  endif

  if (meta_rflx(ixRFLX%dlayRunoff)%varFile) then
   ! write routed local runoff in each stream segment (m3/s)
   call write_nc(trim(fileout), 'dlayRunoff', RCHFLX(iens,:)%BASIN_QR(1), (/1,jTime/), (/nRch,1/), ierr, cmessage)
   if(ierr/=0)then; message=trim(message)//trim(cmessage); return; endif
  endif

  if (meta_rflx(ixRFLX%sumUpstreamRunoff)%varFile) then
   ! write accumulated runoff (m3/s)
   call write_nc(trim(fileout), 'sumUpstreamRunoff', RCHFLX(iens,:)%UPSTREAM_QI, (/1,jTime/), (/nRch,1/), ierr, cmessage)
   if(ierr/=0)then; message=trim(message)//trim(cmessage); return; endif
  endif

  if (meta_rflx(ixRFLX%KWTroutedRunoff)%varFile) then
   ! write routed runoff (m3/s)
   call write_nc(trim(fileout), 'KWTroutedRunoff', RCHFLX(iens,:)%REACH_Q, (/1,jTime/), (/nRch,1/), ierr, cmessage)
   if(ierr/=0)then; message=trim(message)//trim(cmessage); return; endif
  endif

  if (meta_rflx(ixRFLX%IRFroutedRunoff)%varFile) then
   ! write routed runoff (m3/s)
   call write_nc(trim(fileout), 'IRFroutedRunoff', RCHFLX(iens,:)%REACH_Q_IRF, (/1,jTime/), (/nRch,1/), ierr, cmessage)
   if(ierr/=0)then; message=trim(message)//trim(cmessage); return; endif
  endif

 END SUBROUTINE output


 ! *********************************************************************
 ! public subroutine: define routing output NetCDF file
 ! *********************************************************************
 SUBROUTINE prep_output(ierr, message)    ! out:   error control

 ! saved public variables (usually parameters, or values not modified)
 USE public_var,          only : calendar          ! calendar name
 USE public_var,          only : newFileFrequency  ! frequency for new output files (day, month, annual)
 USE public_var,          only : time_units        ! time units (seconds, hours, or days)
 ! saved global data
 USE globalData,          only : basinID,reachID   ! HRU and reach ID in network
 USE globalData,          only : modJulday         ! julian day: at model time step
 USE globalData,          only : modTime           ! previous and current model time
 USE globalData,          only : nEns, nHRU, nRch  ! number of ensembles, HRUs and river reaches
 ! subroutines
 USE time_utils_module,   only : compCalday        ! compute calendar day
 USE time_utils_module,   only : compCalday_noleap ! compute calendar day

 implicit none

 ! input variables: none
 ! output variables
 integer(i4b), intent(out)       :: ierr             ! error code
 character(*), intent(out)       :: message          ! error message
 ! local variables
 logical(lgt)                    :: defnewoutputfile ! flag to define new output file
 character(len=strLen)           :: cmessage         ! error message of downwind routine

 ! initialize error control
 ierr=0; message='prep_output/'

  ! get the time
  select case(trim(calendar))
   case('noleap')
    call compCalday_noleap(modJulday,modTime(1)%iy,modTime(1)%im,modTime(1)%id,modTime(1)%ih,modTime(1)%imin,modTime(1)%dsec,ierr,cmessage)
   case ('standard','gregorian','proleptic_gregorian')
    call compCalday(modJulday,modTime(1)%iy,modTime(1)%im,modTime(1)%id,modTime(1)%ih,modTime(1)%imin,modTime(1)%dsec,ierr,cmessage)
   case default;    ierr=20; message=trim(message)//'calendar name: '//trim(calendar)//' invalid'; return
  end select
  if(ierr/=0)then; message=trim(message)//trim(cmessage); return; endif

  ! print progress
  print*, modTime(1)%iy,modTime(1)%im,modTime(1)%id,modTime(1)%ih,modTime(1)%imin

  ! *****
  ! *** Define model output file...
  ! *******************************

  ! check need for the new file
  select case(trim(newFileFrequency))
   case('single'); defNewOutputFile=(modTime(0)%iy==integerMissing)
   case('annual'); defNewOutputFile=(modTime(1)%iy/=modTime(0)%iy)
   case('month');  defNewOutputFile=(modTime(1)%im/=modTime(0)%im)
   case('day');    defNewOutputFile=(modTime(1)%id/=modTime(0)%id)
   case default; ierr=20; message=trim(message)//'unable to identify the option to define new output files'; return
  end select

  ! define new file
  if(defNewOutputFile)then

   ! initialize time
   jTime=1

   ! update filename
   write(fileout,'(a,3(i0,a))') trim(output_dir)//trim(fname_output)//'_', modTime(1)%iy, '-', modTime(1)%im, '-', modTime(1)%id, '.nc'

   ! define output file
   call defineFile(trim(fileout),                         &  ! input: file name
                   nEns,                                  &  ! input: number of ensembles
                   nHRU,                                  &  ! input: number of HRUs
                   nRch,                                  &  ! input: number of stream segments
                   time_units,                            &  ! input: time units
                   calendar,                              &  ! input: calendar
                   ierr,cmessage)                            ! output: error control
   if(ierr/=0)then; message=trim(message)//trim(cmessage); return; endif

   ! define basin ID
   call write_nc(trim(fileout), 'basinID', basinID, (/1/), (/nHRU/), ierr, cmessage)
   if(ierr/=0)then; message=trim(message)//trim(cmessage); return; endif

   ! define reach ID
   call write_nc(trim(fileout), 'reachID', reachID, (/1/), (/nRch/), ierr, cmessage)
   if(ierr/=0)then; message=trim(message)//trim(cmessage); return; endif

  ! no new file requested: increment time
  else

   jTime = jTime+1

  endif

  modTime(0) = modTime(1)

 END SUBROUTINE prep_output


 ! *********************************************************************
 ! private subroutine: define routing output NetCDF file
 ! *********************************************************************
 SUBROUTINE defineFile(fname,           &  ! input: filename
                       nEns_in,         &  ! input: number of ensembles
                       nHRU_in,         &  ! input: number of HRUs
                       nRch_in,         &  ! input: number of stream segments
                       units_time,      &  ! input: time units
                       calendar,        &  ! input: calendar
                       ierr, message)      ! output: error control
 !Dependent modules
 USE public_var,  ONLY: mizuRouteVersion
 USE globalData, ONLY: meta_rflx
 USE globalData, ONLY: meta_qDims
 USE var_lookup, ONLY: ixRFLX, nVarsRFLX
 USE var_lookup, ONLY: ixQdims, nQdims

 implicit none
 ! input variables
 character(*), intent(in)        :: fname        ! filename
 integer(i4b), intent(in)        :: nEns_in      ! number of ensembles
 integer(i4b), intent(in)        :: nHRU_in      ! number of HRUs
 integer(i4b), intent(in)        :: nRch_in      ! number of stream segments
 character(*), intent(in)        :: units_time   ! time units
 character(*), intent(in)        :: calendar     ! calendar
 ! output variables
 integer(i4b), intent(out)       :: ierr         ! error code
 character(*), intent(out)       :: message      ! error message
 ! local variables
 character(len=strLen),allocatable :: dim_array(:)
 integer(i4b)                      :: nDims
 integer(i4b)                      :: ixDim
 integer(i4b)                      :: ncid         ! NetCDF file ID
 integer(i4b)                      :: jDim, iVar   ! dimension, and variable index
 character(len=strLen)             :: cmessage     ! error message of downwind routine

 ! initialize error control
 ierr=0; message='defineFile/'

 associate (dim_seg  => meta_qDims(ixQdims%seg)%dimName,    &
            dim_hru  => meta_qDims(ixQdims%hru)%dimName,    &
            dim_ens  => meta_qDims(ixQdims%ens)%dimName,    &
            dim_time => meta_qDims(ixQdims%time)%dimName)

! populate q dimension meta (not sure if this should be done here...)
 meta_qDims(ixQdims%seg)%dimLength = nRch_in
 meta_qDims(ixQdims%hru)%dimLength = nHRU_in
 meta_qDims(ixQdims%ens)%dimLength = nEns_in

 ! Modify write option
 ! Routing option
 if (routOpt==kinematicWave) then
  meta_rflx(ixRFLX%IRFroutedRunoff)%varFile = .false.
 elseif (routOpt==impulseResponseFunc) then
  meta_rflx(ixRFLX%KWTroutedRunoff)%varFile = .false.
 endif
 ! runoff accumulation option
 if (doesAccumRunoff==0) then
  meta_rflx(ixRFLX%sumUpstreamRunoff)%varFile = .false.
 endif
 ! basin runoff routing option
 if (doesBasinRoute==0) then
  meta_rflx(ixRFLX%instRunoff)%varFile = .false.
 endif

 ! --------------------
 ! define file
 ! --------------------
 call def_nc(trim(fname), ncid, ierr, cmessage, nctype=netcdf_format)
 if(ierr/=0)then; message=trim(message)//trim(cmessage); return; endif

 do jDim =1,nQdims
   if (jDim ==ixQdims%time) then ! time dimension (unlimited)
    call def_dim(ncid, trim(meta_qDims(jDim)%dimName), ncd_unlimited, meta_qDims(jDim)%dimId, ierr, cmessage)
   else
    call def_dim(ncid, trim(meta_qDims(jDim)%dimName), meta_qDims(jDim)%dimLength ,meta_qDims(jDim)%dimId, ierr, cmessage)
   endif
  if(ierr/=0)then; message=trim(message)//trim(cmessage); return; endif
 end do

 ! Define coordinate variable for time
 call def_var(ncid, trim(dim_time), (/dim_time/), ncd_double, ierr, cmessage, vdesc=trim(dim_time), vunit=trim(units_time), vcal=calendar)
 if(ierr/=0)then; message=trim(message)//trim(cmessage); return; endif

 ! Define ID variable for time
 call def_var(ncid, 'basinID', (/dim_hru/), ncd_int, ierr, cmessage, vdesc='basin ID', vunit='-')
 if(ierr/=0)then; message=trim(message)//trim(cmessage); return; endif
 call def_var(ncid, 'reachID', (/dim_seg/), ncd_int, ierr, cmessage, vdesc='reach ID', vunit='-')
 if(ierr/=0)then; message=trim(message)//trim(cmessage); return; endif

 ! define variables
 do iVar=1, nVarsRFLX

  if (.not.meta_rflx(iVar)%varFile) cycle

  ! define dimension ID array
  nDims = size(meta_rflx(iVar)%varDim)
  if (allocated(dim_array)) then
    deallocate(dim_array)
  endif
  allocate(dim_array(nDims))
  do ixDim = 1, nDims
    dim_array(ixDim) = meta_qDims(meta_rflx(iVar)%varDim(ixDim))%dimName
  end do

  call def_var(ncid, meta_rflx(iVar)%varName, dim_array, meta_rflx(iVar)%varType, ierr, cmessage, vdesc=meta_rflx(iVar)%varDesc, vunit=meta_rflx(iVar)%varUnit )
  if(ierr/=0)then; message=trim(message)//trim(cmessage); return; endif

 end do

 end associate

 ! put global attribute
 call put_global_attr(ncid, 'version', trim(mizuRouteVersion) ,ierr, cmessage)
 if(ierr/=0)then; message=trim(message)//trim(cmessage); return; endif

 ! end definitions
 call end_def(ncid, ierr, cmessage)
 if(ierr/=0)then; message=trim(message)//trim(cmessage); return; endif

 ! close NetCDF file
 call close_nc(ncid, ierr, cmessage)
 if(ierr/=0)then; message=trim(message)//trim(cmessage); return; endif

 END SUBROUTINE defineFile


END MODULE write_simoutput
