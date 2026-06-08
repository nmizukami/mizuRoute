
.. _Reach_routing_oveall_workflow:

Overall workflow
======================

Overall computation workflow is shown in :numref:`Figure_overall_comp_workflow`. Starting with runoff depth from netCDF or coupler (e.g. CTSM coupling),

#. Remap runoff depth [m/s] to river network HRU (Hydrologic Response Unit or simply catchment), :math:`R_{lat}`, if runoff is given at hydrologic model HRU

#. Convert :math:`R_{lat}` from depth unit to volume (:math:`R_{lat}` times HRU area) to get lateral runoff volume (:math:`q_{lat}`) [m3/s]

#. Perform hillslope routing to delay lateral runoff volume, if travel time of runoff is not counted outside mizuRoute.

#. Route inflow from upstream and add delayed lateral discharge to routed inflow at each river reach outlet.

The hillslope routing method currently uses a simple unit hydrograph based on gamma distribution (only one method available) to delay instantaneous runoff.
See the next section :ref:`Hillslope routing scheme <Hillslope_routing_scheme>`).

The river reach or lake routing needs to be performed in the order of upstream-to-downstream to complete the routing in the entire river network. The section :ref:`navigate_river_network` describe how mizuRoute navigates the river network from the headwater to outlet of the basins.

.. _Figure_overall_comp_workflow:

.. figure:: images/overall_comp_workflow.png
 :width: 700
 :height: 400

 Overall routing procedures from runoff input into model to streamflow computation.
