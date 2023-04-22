====
Pass
====

The LLVM pass framework is an important part of the LLVM system, because LLVM passes are where the most interesting parts of the compiler exist.
Passes perform transformations and optimizations that make up the compiler, they build the analysis results that are used by these transformations, and they are, above all, a structuring technique for compiler code.

An LLVM pass can be regarded as a black box that takes LLVM IR as input and produces outputs depending on what kind the pass is.
There’re two kinds of passes: *transformation pass* and *analysis pass*.
For a transformation pass, it typically modifies the input IR and produces the transformed IR.
Code generation passes that output SelectionDAG and machine IR from input LLVM IR are also transformation passes.
For an analysis pass, it does not modify the input IR, but it looks into the IR and produces certain information that describes some properties about the input IR.
Transformation passes typically implement compiler optimizations, program transformation, program instrumentation and other tasks.
Analysis passes typically provide necessary information for the transformation passes to work.

Real-world compilers usually rely on hundreds of passes that run one after another on the generated IR to complete optimization and code generation.
This sequence of passes that run one after another is also called *the pipeline*.
Note that different compiler configurations may end with different pipeline configurations, affecting the set of passes used and their execution order.

Passes can have *dependencies*.
For example, a transformation pass cannot work until its required analysis passes have been run.
Also, some transformation passes can invalidate cached code properties analyzed by a previous analysis pass.
LLVM uses *pass managers* to manage available passes and schedule the pass pipeline properly onto the input IR.
Unfortunately, due to historical reasons, LLVM has two flavors of pass managers at now: the new pass manager and the legacy pass manager.
This wiki primarily talks about the new pass manager, and the LLVM community is migrating to the new pass manager and deprecating the legacy one.

Write a Hello World Pass
========================

In this section, we guide you through writing and running a simple pass that prints the names of all functions contained in the input IR module.

Setup the Build
---------------

Let’s assume that you have cloned the `LLVM monorepo <https://github.com/llvm/llvm-project>`__ and setup the build directory at ``build/``  [1]_, and the current working directory is the root of the monorepo.
In this section, we will build the new pass in-tree, which means that the source tree of the new pass is directly embedded in the source tree of the LLVM monorepo.

Create a ``Hello.h`` file under ``llvm/include/llvm/Transforms/Utils/``:

.. code:: sh

   touch llvm/include/llvm/Transforms/Utils/Hello.h

Create a ``Hello.cpp`` file under ``llvm/lib/Transforms/Utils/``:

.. code:: sh

   touch llvm/lib/Transforms/Utils/Hello.cpp

Modify ``llvm/lib/Transforms/Utils/CMakeLists.txt`` and add
``Hello.cpp`` to the ``add_llvm_component_library`` call:

.. code:: cmake

   add_llvm_component_library(LLVMTransformUtils
       # Other files ...
       Hello.cpp
       # Other files and configurations ...
   )

This step adds ``Hello.cpp`` to the LLVM build process.

Code Implementation
-------------------

Edit ``Hello.h`` as follows:

.. code:: cpp

   #ifndef LLVM_TRANSFORMS_HELLO_H
   #define LLVM_TRANSFORMS_HELLO_H

   #include "llvm/IR/PassManager.h"

   namespace llvm {

   class HelloPass : public PassInfoMixin<HelloPass> {
   public:
     PreservedAnalyses run(Function &F, FunctionAnalysisManager &AM);
   };

   }  // namespace llvm

   #endif

Edit ``Hello.cpp`` as follows:

.. code:: cpp

   #include "llvm/Transforms/Utils/Hello.h"

   namespace llvm {

   PreservedAnalyses HelloPass::run(Function &F, FunctionAnalysisManager &AM) {
     errs() << F.getName() << "\n";
     return PreservedAnalyses::all();
   }

   }  // namespace llvm

Yes! This is (almost) all you need to write a simple but working pass.
Let’s break the code into pieces and see how it’s working.

To create a pass in C++, you need to write a class that implements the software interface of a pass.
Unlike traditional approaches which rely on class inheritance, the new pass manager uses *concepts-based polymorphism*  [2]_  [3]_.
**As long as the class contains a ``run`` method that allows it to run on some piece of IR, it is a pass**.
No need to inherit the class from some base class and override some virtual functions.
In the code above, our ``HelloPass`` class inherits from the ``PassInfoMixin`` class, which adds some boilerplate code to the pass.
But the most important part is the ``run`` method that makes ``HelloPass`` a pass.

The ``run`` method takes two parameters.
The first parameter ``F`` is the IR function that the pass is running on.
Note that ``F`` is passed via a non-const reference, indicating that we can modify the function (i.e. perform transformations) in the pass.
The second parameter ``AM`` is a pass manager instance that links to analysis passes and provides function-level analysis information.

Since the ``run`` method takes ``Function`` as input, ``HelloPass`` is a **function pass**.
The pass manager schedules a function pass to run on every function in the input IR module.
When the ``HelloPass`` gets executed, it writes the function’s name to the standard error and finishes.

The ``run`` method returns a ``PreservedAnalyses`` object.
This object contains information about whether the analysis performed by a previous analysis pass is still valid after this pass runs.
The ``run`` method returns ``PreservedAnalyses::all()`` to indicate that all available analysis is still valid after running ``HelloPass`` (because it doesn’t modify the IR).

Register the Pass
-----------------

We have finished implementing the simple pass but we havn’t told LLVM pass manager about the existance of our new pass.
We need to *register* our new pass into the pass manager.

Edit ``llvm/lib/Passes/PassRegistry.def`` and add the following lines to it:

.. code:: cpp

   FUNCTION_PASS("hello", HelloPass())

Note the first argument to ``FUNCTION_PASS`` is the name of our new pass.

Add the following ``#include`` to ``llvm/lib/Passes/PassBuilder.cpp``:

.. code:: cpp

   #include "llvm/Transforms/Utils/Hello.h"

and it’s done. Now time for building and running our new pass.

Build and Run
-------------

Go to the build directory and build ``opt``, which is a dedicated tool for running passes over a piece of IR.
After building ``opt``, create a test IR file ``test.ll`` for testing:

.. code:: llvm

   define i32 @foo() {
     %a = add i32 2, 3
     ret i32 %a
   }

   define void @bar() {
     ret void
   }

Then run our new pass with ``opt``:

.. code:: sh

   build/bin/opt -disable-output test.ll -passes=hello

The ``-passes=hello`` option make ``opt`` run ``HelloPass``.

Expected output:

::

   foo
   bar

Congratulations! You have finished your LLVM pass!

.. [1]
   For instructions on how to build LLVM from source, please refer to
   the `official
   documentation <https://llvm.org/docs/GettingStarted.html#getting-the-source-code-and-building-llvm>`__.

.. [2]
   You can refer to `this
   comment <https://github.com/llvm/llvm-project/blob/main/llvm/include/llvm/IR/PassManager.h#L27-L33>`__
   for a brief introduction to the concepts-based polymorphism used in
   the pass framework.

.. [3]
   For a detailed introduction and discussion about concepts-based
   polymorphism, please refer to `GuillaumeDua. Concept-based
   polymorphism in modern
   C++ <https://gist.github.com/GuillaumeDua/b0f5e3a40ce49468607dd62f7b7809b1>`__.
