
.. _navigate_river_network:

Navigate river network
=======================

MizuRoute performs reach routing scheme(s) from headwater reaches to outlet of the river basin in the order so that at each computing time step, outflow from one reach can be passed to immediate downstream reach.
Key parameters of river network topology is reach ID (segId) and immediate downstream reach ID (downSegId). Similarly, HRU has HRU id (HRUid) and ID of reach that runoff from this HRU flows into (hruSegId). These four parameters are all needed to figure out the routing order in the given river network.
A example of routing order in a river basin is shown here.


.. _domain_decomposition:

Domain decomposition
=======================

MizuRoute can support MPI parallel computing, where the river network is split into many independent tributary domains and mainstem domain which all the tributary domain eventually flows into. Given a number of MPI task (i.e., computing core), mizuRoute assigns each tributary domain into task (i.e., computing core) including main task such that total number of reaches assigned to each task are approximately similar.
Currently, mizuRoute use total upstream reach number as a guidance to delineate tributary domains. Any reaches below tributary domains is defined as mainstem domain. For parallel computing, all the tasks compute tributary reaches simultaneously, but mainsteam domain has to wait till all the tributary reaches are all routed. After tributary reach routing, discharge at outlet of each tributary domain is communicated to main task and passed to ghost reach that immediate upstream of very top of mainstem reaches, so that mainstem routing can properly route upstream flow from the tributary domain.

Additionally, each tributary domain can be further split into multiple tributaries, which can be parallelized using shared memory OpenMP within each MPI task.

This parallelization scheme is described in :ref:`Mizukami et al. (2021) <Mizukami2021>`.


this section is working in progress.....
