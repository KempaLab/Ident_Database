# Ident-Mix Spectra Database

## About

This project contains the GC-EI-MS spectra database described in the publication _"Towards a more reliable identification of isomeric
metabolites using pattern guided retention validation"_. With this concept it is possible to validate the retention behaviour for multiple metabolites simultanously, so identification of metabolites is more reliable and faster.

<img src=images/abstract.png width = "50%">

## Installation and usage

The spectra are stored as `.msp` text file. Some programmes (e.g. [MAUI-VIA](https://www.frontiersin.org/articles/10.3389/fbioe.2014.00084/full])) already read `.msp` format, just save the file to the correct directory. 
For other programmes you may need to convert this file to the NISTMS-folder database-style. For this we recommend the use of the [Library Conversion Tool](https://chemdata.nist.gov/mass-spc/ms-search/Library_conversion_tool.html) from NIST.
Usually then the folder has to be saved in the NISTMS folder. Check the instructions of your software. 

## Information stored in the spectra database

The metabolite names contain additional information useful for working with the spectra database. All entities are sperated by an underscore, so they can be conveniently stripped off.    
For example `Butanoic acid, 4-amino-_(3TMS)_MP_RI:1527_IDENT:A+C` contains:
 * The name of the compound: `Butanoic acid, 4-amino-` Note that the compounds are named according to their main structure, here `Butanoic acid`, followed the modifications, here `4-amino-`.
 * The derivatisation state, here it contains 3 trimethyl-silyl (TMS) groups.
 * If this compound is the main product (`MP`) or byproduct (`BP`). MP indicates the derivatisation state that usually gives the highest intensity. 
 * The retention index, based on a semipolar column (5%-phenyl)-methylpolysiloxane with _n_-alkane retention index system
 * The occurence pattern in the Ident mixes, here in `A` and `C`.
