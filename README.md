# Ident-Mix Spectra Database

## About

This projects contain the GC-EI-MS spectra database described in the publication "Towards a more reliable identification of isomeric
metabolites using pattern guided retention validation". With this concept it is possible to validate the retention behaviour for multiple metabolites simultanously, so identification of metabolites is more reliable and faster.
<img src=images/abstract.png width = "75%">

## Installation and usage

The spectra are stored as .msp text file. Some software (e.g. MAUI-VIA) already read this msp format, just copy the file into the right folder. 
For other you need to convert this file to the NISTMS-folder -style. For this we recommend the use of the Library Conversion Tool: 
https://chemdata.nist.gov/mass-spc/ms-search/Library_conversion_tool.html
Usually then the folder needs to be saved in the NISTMS folder. Check the instruction of your software supplier. 

## Information stored in the spectra database

The metabolite names contain additional information useful for working with the spectra database. All entities are sperated by an underscore, so they can stripped off.    
For example "Butanoic acid, 4-amino-_(3TMS)_MP_RI:1527_IDENT:A+C" contains:
 * The name of the compound: Butanoic acid, 4-amino- Not that the compounds are named first by their main structure, here Butanoic acid, then the modifications follow, here 4-amino.
 * The derivatisation state, here it contains 3 trimethylsilyl (TMS) groups.
 * If this peak is the main product (MP) or byproduct (BP). Here it indicates the derivatisation state that usually gives the highest intensity. 
 * The retention index, based on a semipolar column (5%-phenyl)-methylpolysiloxane with n-alkane retention index system
 * The occurence pattern in the Ident mixes, here in A and C.
