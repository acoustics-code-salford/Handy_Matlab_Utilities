# Handy_Matlab_Utilities
A repo in which to store handy Matlab utility functions that others may wish to reuse. These are anticipated to be quite lightweight, but could be anything that is widely useful. Feel free to contribute - just be sure to log in here and as comments within the file what it does and what arguements it requires (if relevant).

* [ProgressBarList.m](ProgressBarList.m) is like Matlab's built-in [https://www.mathworks.com/help/matlab/ref/waitbar.html](waitbar) function except that it allows a hierachy of waitbars, suitable for nested for-loops or job lists. Completion times are automatically estimated for each level (based on simple linear extrapolation).
* [SetAllPlotTextToLatex.m](SetAllPlotTextToLatex.m) sets Matlab's root graphic preferences so that all plot text interpretation defaults to LaTeX.
* [tex_underscore.m](tex_underscore.m) converts underscores to the tex version of underscores, so that underscores are displayed correctly in figure captions.
* [unwrap_from_index](unwrap_from_index) is like Matlab's built-in [https://www.mathworks.com/help/matlab/ref/unwrap.html](unwrap), but starts from bin i and unwraps bidirectionally from there. It is useful when data at both ends of an array (e.g. a spectrum) is noisy, so you want to start the phase unwrapping from a known bin where the data is reliable.
