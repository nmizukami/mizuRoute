
.. _diffusive-wave_equation_derivation:

Diffusive-Wave Equation Derivation
==================================

If advection and inertia terms are neglected (i.e., the 1st and 2nd terms in LHS of :eq:`0.2`), the simplified momentum equation is

.. math::
   :label: 1.1

   \frac{\partial h}{\partial x} + S_f = S_0

or equivalently,

.. math::
   :label: 1.2

   S_f = S_0 - \frac{\partial h}{\partial x}

where

- :math:`h` is flow height [m],
- :math:`S_f` is friction slope [m/m],
- :math:`S_0` is bed slope [m/m].

Based on Eq :eq:`0.3`, the conveyance relation is written as

.. math::
   :label: 1.3

   Q = K\sqrt{S_f}

A key point is that :math:`S_f` is not generally independent of :math:`A` in the full diffusive-wave relation, because
:math:`h` is related to :math:`A` in Eq :eq:`1.2`. Therefore, if we take the total differentials of Eq :eq:`1.3`, we can write

.. math::
   :label: 1.4

   dQ =
   \left(\frac{\partial Q}{\partial A}\right)_{S_f} dA
   +
   \left(\frac{\partial Q}{\partial S_f}\right)_A dS_f

The first term gives the kinematic-wave celerity:

.. math::
   :label: 1.5

   C =
   \left(\frac{\partial Q}{\partial A}\right)_{S_f}
   =
   \sqrt{S_f}\frac{\partial K}{\partial A}
   =
   \frac{Q}{K}\frac{\partial K}{\partial A}

The subscript :math:`S_f` means that :math:`C` is the partial derivative of :math:`Q` with respect to :math:`A` while holding :math:`S_f` fixed.

The second term derivative is

.. math::
   :label: 1.6

   \left(\frac{\partial Q}{\partial S_f}\right)_A
   =
   \frac{K}{2\sqrt{S_f}}
   =
   \frac{K^2}{2Q}

Therefore,

.. math::
   :label: 1.7

   dQ = C\,dA + \frac{K^2}{2Q}dS_f

Using the diffusive-wave momentum approximation,

.. math::
   :label: 1.8

   dS_f = -d\left(\frac{\partial h}{\partial x}\right)

For a prismatic channel,

.. math::
   :label: 1.9

   dA = w\,dh

where :math:`w` is the channel top width. Thus,

.. math::
   :label: 1.10

   dh = \frac{dA}{w}

and approximately,

.. math::
   :label: 1.11

   dS_f = -\frac{1}{w}\frac{\partial dA}{\partial x}

Substituting into the total variation of :math:`Q` gives

.. math::
   :label: 1.12

   dQ = C\,dA - \frac{K^2}{2Qw}\frac{\partial dA}{\partial x}

Define the hydraulic diffusivity as

.. math::
   :label: 1.13

   D = \frac{K^2}{2Qw}

Then

.. math::
   :label: 1.14

   dQ = C\,dA - D\frac{\partial dA}{\partial x}

This shows that the dependence of :math:`S_f` on the water-surface slope is not ignored. Instead, it becomes the diffusion term in the final equation. Differentiating with respect to time gives

.. math::
   :label: 1.15

   \frac{\partial Q}{\partial t} = C\frac{\partial A}{\partial t} - D\frac{\partial^2 A}{\partial x \partial t}

From continuity (Eq :eq:`0.1`),

.. math::
   :label: 1.16

   \frac{\partial A}{\partial t} = q_l - \frac{\partial Q}{\partial x}

Differentiating this expression with respect to :math:`x` gives

.. math::
   :label: 1.17

   \frac{\partial^2 A}{\partial x \partial t} =
   \frac{\partial q_l}{\partial x} - \frac{\partial^2 Q}{\partial x^2}

Substituting into the time derivative of :math:`Q`,

.. math::
   :label: 1.18

   \frac{\partial Q}{\partial t} =
   C\left(q_l - \frac{\partial Q}{\partial x}\right)
   -
   D\left(\frac{\partial q_l}{\partial x} - \frac{\partial^2 Q}{\partial x^2}\right)

Rearranging,

.. math::
   :label: 1.19

   \frac{\partial Q}{\partial t} + C\frac{\partial Q}{\partial x} =
   D\frac{\partial^2 Q}{\partial x^2} + Cq_l - D\frac{\partial q_l}{\partial x}

If lateral inflow is spatially uniform within the reach, or if :math:`\partial q_l / \partial x` is neglected, this reduces to

.. math::
   :label: 1.20

   \frac{\partial Q}{\partial t} + C\frac{\partial Q}{\partial x} =
   D\frac{\partial^2 Q}{\partial x^2} + Cq_l

