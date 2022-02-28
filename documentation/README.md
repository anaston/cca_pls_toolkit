# Documentation How-To

Once the toolkit has been released, there will be an online version of the documentation hosted through Github Pages. Until then, you can start a local web server on your computer and **use the generated web page** using Python 3. It should be easy and straightforward if you have been working with Python before (just a little). To make life easier, you can simply try and install everything inside your current Python environment. If you don't want to do that, feel free to create a dedicated Python environment first.

Please find a detailed instruction on how to use the webpage below.

## Installation

We use mkdocs which is a very popular static site generator that creates an HTML-based static website from markdown files. To install the necessary packages, simply run the following command in the terminal window within a Python 3 environment:

```bash
pip install mkdocs-material
pip install mkdocs-with-pdf
pip install --upgrade beautifulsoup4==4.9.3
```

In addition to mkdocs, this will install the material theme https://squidfunk.github.io/mkdocs-material/ and some custom plugins we're using to render Latex and so on. As there is an issue with
the latest version of beautifulsoup which we need to render the Latex equations in the PDF documentation. As we also install mkdocs-with-pdf, a PDF version of the documentation will automatically
be generated.



## How to use it

Within the terminal, navigate to the documentation folder and type:

```bash
make serve
```

If you are using a dedicated Python environment, make sure to activate it before. Once you've run make serve, mkdocs will start a local web server and host the documentation website under:

http://127.0.0.1:8000/

Just follow that link or copy and paste it to your browser. You should now be able to use the documentation from within your browser.

## How to make changes to the documentation

The markdown files from which the website is created come from two different sources. First, __some files are created automatically using matdoc.py and matdocparser.py__ from the MatConvNet MATLAB Toolbox. I've customized some of the code of matdoc and matdocparser for our needs. This was the easiest way to generate most of the documentation from the m-files of toolbox itself. Second, and this is the usual way mkdocs is used, __there are markdown files which are written manually to create a landing page and any other page containing additional information__ that is not included in the m-files of the toolbox (e.g. how to install the toolbox and so on). These files can simply be changed in any text editor. For markdown files, I can recommend Typora which is a very elegant "what you see is what you get" editor.

#### Generate markdown files from MATLAB scripts

To generate the markdown files (which are stored under `documentation/docs/mfiles/`) from the MATLAB function headers, `cd` to the documentation folder and run `make build-mfiles` from the terminal. You should be able to see some output for every function that has been loaded. You can add all the .m-files that should be included in the documentation by adding them to the `makefile` file. You will then also need to add them to the `mkdocs.yml` under the nav section to have them displayed within the website. As the matdoc Python scripts were written in Python 2, we will use this Python version to run matdoc.py when calling `make build-mfiles`. This is why you will need a Python 2 version to build the markdown files from the documentation within the matlab scripts. You don't need to install mkdocs or anything within Python 2. 

#### Build the documentation

To build the static site, run `make build`.

#### Summary of commands

`make serve` : run the web server locally and use the documentation.

`make build-mfiles`: run matdoc to create markdown files from the documentation within m-files

`make build`: build the static website, afterwards Github Pages will be able to built the website

## Github Pages

If we want to use Github Pages to host the documentation website, we will need to change the destination folder for mkdocs inside the makefile. The website needs to be generated inside a 'docs' folder in the root directory of the repository so that Github automatically detects the files. Github Pages will also need to be activated within the settings of the repository.



---

written by Nils Winter (nils.r.winter@gmail.com)
