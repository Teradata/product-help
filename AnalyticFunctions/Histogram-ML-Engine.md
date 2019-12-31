<div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="mcm1507661970733" id="mcm1507661970733"><h1 class="title topictitle1" id="ariaid-title1">Histogram (ML Engine)</h1><div class="body conbody">
<p class="p">Histograms are useful for assessing the shape of a data distribution. The Histogram function calculates the frequency distribution of a data set using either the Sturges or Scott algorithm to compute binning (bin width and number of bins). The <dfn class="term">bin width</dfn> is the range for each group of values. Binning algorithms make strong assumptions about the shape of the distribution. Appropriate bin width depends on the actual data distribution and analysis goals. The function maps each input row to one bin and returns the row count (frequency) and percentage of rows (proportion) of each bin.</p>
<p class="p"><span><b>ML Engine</b></span> histogram implementation includes these capabilities:</p>
<ul class="ul" id="mcm1507661970733__ul_tyj_r4r_p1b">
<li class="li">User-selected or automatic bin determination</li>
<li class="li">User-selected left-inclusive or right-inclusive binning</li>
<li class="li">Multiple histograms for distinct groups</li></ul></div><div class="topic reference nested1" aria-labelledby="ariaid-title2" topicindex="2" topicid="lwc1507662302928" xml:lang="en-us" lang="en-us" id="lwc1507662302928">
<h2 class="title topictitle2" id="ariaid-title2">Histogram Syntax</h2><div class="body refbody"><div class="section" id="lwc1507662302928__section_N1000E_N1000C_N10001">
<h3 class="title sectiontitle">Version 1.5</h3><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM Histogram (
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> AS InputTable
  [ <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> AS CustomBinTable ]
  OUT TABLE OutputTable (<var class="keyword varname">output_table</var>)
  USING
  { AutoBin ({ 'Sturges' | 'Scott' | <var class="keyword varname">number_of_bins</var> }) |
    CustomBinColumn ('<var class="keyword varname">breaks_col</var>') |
    StartValue (<var class="keyword varname">bin_start</var>)
    BinSize (<var class="keyword varname">bin_size</var>)
    EndValue (<var class="keyword varname">bin_end</var>)
  }
  TargetColumn ('<var class="keyword varname">target_column</var>')
  [ Inclusion ({ 'left' | 'right' }) ]
  [ GroupbyColumns ({ '<var class="keyword varname">group_column</var>' | <var class="keyword varname">group_column_range</var> }[,...]) ]
) AS <var class="keyword varname">alias</var>;</code></pre></div><div class="section" id="lwc1507662302928__section_irp_4kj_rbb">
<h3 class="title sectiontitle">Bin Definition Options</h3>
<ul class="ul" id="lwc1507662302928__ul_ftc_pkj_rbb">
<li class="li">The function determines the bin boundaries automatically, using one of two algorithms.</li>
<li class="li">You specify the bin boundaries.</li>
<li class="li">You provide the minimum and maximum values for the histogram and an optional bin size. If you specify a bin size, all bins have that size; if not, bins might not be the same size.</li></ul></div></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title3" topicindex="3" topicid="ino1507662339929" xml:lang="en-us" lang="en-us" id="ino1507662339929">
<h2 class="title topictitle2" id="ariaid-title3">Histogram Syntax Elements</h2><div class="body refbody"><div class="section" id="ino1507662339929__section_N10011_N1000E_N10001"><dl class="dl parml"><dt class="dt pt dlterm">OutputTable</dt><dd class="dd pd">Specify the name for the table that the function creates for the output.</dd><dt class="dt pt dlterm">AutoBin</dt><dd class="dd pd">[Optional] If you specify this syntax element, you must not specify CustomBinTable, CustomBinColumn, StartValue, BinSize, or EndValue.
<p class="p">Specify either the algorithm for selecting bin boundaries or the approximate number of bins to find. The <var class="keyword varname">number_of_bins</var> must be a positive integer.</p>
<p class="p">Sturges algorithm for calculating bin width can be written as:</p>
<p class="p"><code class="ph codeph"><var class="keyword varname">w</var> = <var class="keyword varname">r</var>/(1 + log<span><sub>2</sub></span><var class="keyword varname">n</var>)</code></p>
<p class="p">where <var class="keyword varname">w</var> is the bin width, <var class="keyword varname">r</var> is the range of the data values and <var class="keyword varname">n</var> is the number of elements in the data set. Sturges algorithm performs best if the data is normally distributed and <var class="keyword varname">n</var> is at least 30.</p>
<p class="p">The Scott algorithm for calculating bin width can be written as:</p>
<p class="p"><code class="ph codeph"><var class="keyword varname">w</var> = 3.49<var class="keyword varname">s</var>/(<var class="keyword varname">n</var><span><sup>1/3</sup></span>)</code></p>
<p class="p">where <var class="keyword varname">w</var> is the bin width, <var class="keyword varname">s</var> is the standard deviation of the data values and <var class="keyword varname">n</var> is the number of elements in the data set. The number of bins is <var class="keyword varname">r</var>/<var class="keyword varname">w</var>, where <var class="keyword varname">r</var> is the range of the data values. The Scott algorithm performs best on normally distributed data.</p></dd><dt class="dt pt dlterm">CustomBinColumn</dt><dd class="dd pd">[Required if you specify CustomBinTable, disallowed otherwise.] If you specify this syntax element, you must not specify AutoBin, StartValue, BinSize, or EndValue.
<p class="p">Specify the name of the CustomBinTable column that contains the boundary values. This column must have a numeric SQL data type.</p></dd><dt class="dt pt dlterm">StartValue</dt><dd class="dd pd">[Optional] If you specify this syntax element, you must also specify BinSize and EndValue, and you must not specify AutoBin, CustomBinTable, or CustomBinColumn.
<p class="p">Specify the smallest value to use in binning.</p></dd><dt class="dt pt dlterm">EndValue</dt><dd class="dd pd">[Optional] If you specify this syntax element, you must also specify StartValue and BinSize, and you must not specify AutoBin, CustomBinTable, or CustomBinColumn.
<p class="p">Specify the largest value to use in binning.</p></dd><dt class="dt pt dlterm">BinSize</dt><dd class="dd pd">[Optional] If you specify this syntax element, you must also specify StartValue and EndValue, and you must not specify AutoBin, CustomBinTable, or CustomBinColumn.
<p class="p">Specify this syntax element only for equally sized bins. The <var class="keyword varname">bin_size</var> is the width of each bin, a positive DOUBLE PRECISION value.</p></dd><dt class="dt pt dlterm">GroupByColumns</dt><dd class="dd pd">[Optional] Specify the names of the InputTable columns that contain the group values for binning. These columns cannot contain DOUBLE PRECISION values.</dd><dt class="dt pt dlterm">Inclusion</dt><dd class="dd pd">[Optional] Specify whether to include points on bin boundaries in the bin on the left or the bin on the right.</dd><dd class="dd pd ddexpand">Default: 'left'</dd><dt class="dt pt dlterm">TargetColumn</dt><dd class="dd pd">Specify the name of the InputTable column for which to compute statistics. This column must have a numeric SQL data type.</dd></dl></div></div></div></div>
