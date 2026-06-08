
.. _Hillslope_routing_scheme:

Hillslope routing scheme
========================

MizuRoute uses a similar concept to a unit-hydrograph commonly used in engineering hydrology to account for travel time of instantaneous runoff to the river reach (delay and attenuate runoff).
A unit-hydrograph is defined by a hydrograph (time series of discharge) that is derived from a unit depth of excess rainfall on a drainage area within a specific time period.
Here, this concept is applied to directly runoff volume over a HRU, instead of rainfall excess over a drainage area.
Therefore, a unit-hydrograph represents a time series of lateral discharge into a river reach from a HRU derived from a unit volume of runoff.
Here, a probability density function (PDF) is used as a unit-hydrograph, so that cumulative sum of PDF is 1.0.
This means that runoff volume at a current time step is just distributed in the future, with the sum of future distributed runoff is equal to the current runoff volume (i.e., volume conserved)

To get actual delayed lateral flow series to the river reach, unit-hydrograph convolution is performed as below:

.. _Figure_uh_convolution:

.. figure:: images/uh_convolution.png
 :width: 700
 :height: 500

 Illustration of discrete Unit hydrograph convolution.

In mizuRoute, gamma distribution is used for PDF-based unit-hydrograph and written as:

.. math::
   :label: gamma_distribution

   f(t; a, \theta) = \frac{1}{\Gamma(a)\theta^{a}}t^{a - 1} e^{-\frac{t}{\theta}},
   \quad t > 0

where *t* is time [sec], *a* is a shape parameter [–] (a > 0), and :math:`\theta` is a timescale parameter [sec].
Both the shape and timescale parameters affect the peak time of (mode of the distribution: :math:`(a - 1)\theta` and flashiness (variance of the distribution: :math:`a\theta^2` of the unit-hydrograph (UH).
These UH should depend on the physical HRU characteristics. Continuous gamm distribution is descritized per time step before the convolution performed.
These shape and scale parameters are currently specified as a spatially constant parameter (see :ref:`Spatially-constant parameter namelist <namelist_file>`), though they could be provided as spatially distributed parameters from river data netCDF (potential future implementation)

Also, please see section 3.1 in :ref:`Mizukami et al. 2016 <Mizukami2016>` for hillslope routing theory.

