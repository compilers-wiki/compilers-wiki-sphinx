# Compilers Wiki

## Why?

Compiler optimizations and related principles are taught in university courses and university textbooks,
while there are a large number of documents for program optimization performed by compilation technology,
but they are scattered everywhere and cannot be studied intensively.
This warehouse is a description document that contains a large number of compiler-related optimization technologies.
The content is mainly high-level design principles and design implementations.

## Installation and testing

<details>

<summary><b>1. Checkout this repository</b></summary>

Firstly clone our repo, you may need a shallow clone via `--depth=1`

```sh
git clone https://github.com/compilers-wiki/compilers-wiki-sphinx.git compilers-wiki && cd compilers-wiki
```

</details>

<details>

<summary><b>2. Install dependencies</b></summary>

Dependencies listed in `requirements.txt` should work out of box.
Our CI employes "nix" package manager by default to ensure reproducibility, in `flake.nix`.

</details>

<details>

<summary><b>3. Build docs</b></summary>

```
make html
```

The rendered HTML pages should be written into `_build/html`.

</details>


## Contribute to this repository

We currently accept Github Pull Requests.

## License

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br />This work is licensed under <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
