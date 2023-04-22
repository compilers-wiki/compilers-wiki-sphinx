============
Introduction
============

Parallelism
===========

.. TODO: elaborate

Improvements in computer speeds result of two phenomena.

#. Machines advances remarkable by Moore's law.
#. Technology by itself has not been enough.

Parallelism is necessary to keep performance on the track (to following the Moore's law).
Clearly parallelism is essential to supercomputing.

Parallelism is not just for supercomputers.
The growth of image processing applications and multimedia on the desktop created enormous thirst for more processing power.
Features employing parallelism: multiple functional units, multiple-issue instruction processing, and attached vector units.

Compilers' Role
===============

Advances in computing power have not come without problems.
Programmers needs to study how to adopt to these complexy computing systems.
For example, in an effort to squeeze more performance out of individual processors,
programmers have to learn hwo to transform theire codes by hand to imporve instruction scheduling on multiple-issue uniprocessors.

In fact, most of these hand transformations for high performance computers should really be performed by the compiler, libraries, and run-time system.
Reason: compiler has the responsibiliy for translating programs from a language suitable for use by human application developers to the native language of target machine.

Compiler must produce *effcient* result.
Not only *correct*.

Compiler technology has become even more important as machines have become more complex.
However, compiler technology has been only partially successful, excellent techniques has been developed for vectorization, instruction scheduling, and management of multilevel memory hierarchies.
Auto-vectorization, on the other hand, has been successful only for shared-memory parallel systems with a few processors.
Vectorization for scalable machines is still an unsolved problem today.
For example, on scalable vector architectures, like RISC-V with 'V' extension, ARM SVE, LLVM loop vectorizer currently fallbacks into SIMD codes, without utilizing target features.

Challenges arises while considering the diverse collection of high-performance computer architectures. There are many variants of vector registers, different vector length, and different set of target features.

.. TODO: add a image/table about different target features here

Dependencies
============

There is substantive commonality in the underlying analysis structure suitable for general modern HPC computer architectures today.

.. TODO: example about *statement instances*

In general, many critical compilation tasks could be handled by reordering *statement instances* from the original program.
To preserve the observable behavior of the original program, we need to ensure that the transformation does not break any *dependence*.

.. note::

    The concept *dependence* we employed here indicates that it is **unsafe** to interchange the order of two statement instances.

Currently, dependence analysis is widely used in many notable compilers projects.

Vectorization Methodology
=========================

After check the dependencies, there are two basic methods raising scalar codes: Loop & SLP.
Loop vectorization is the most common case.

The compiler takes each statement accessing indices for dependence analysis, and rewrite statements in loop as vectorized representation.

.. TODO: Example here

SLP vectorizer focuses on improving parallelism among slimilar scalar instructions, and trying to pack them into vector instructions.

.. TODO Example here


Granularity
===========

Compilers work on different code abstraction levels, including instructions, basic blocks, procedures, translation units, and excutables.

Vectorization is typically applied on small basic block sets, mostly, the inner most loop, for Loop vectorizer.
However, recent researchers developed whole-procedure vectorization.

Polyhedral Model
================

Interestingly, vectorization was excluded by researchers focusing on polyhedral modes.
Polyhedral compilation maily includes dependence analysis, scheduling, transformation, and code generation.
.. TODO

Misc
====

- Data alignment
- Interleaved
- Control flow
