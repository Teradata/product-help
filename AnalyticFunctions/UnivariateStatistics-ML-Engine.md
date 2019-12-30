<html><head></head><body><div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="ulp1514493205765" id="ulp1514493205765"><h1 class="title topictitle1" id="ariaid-title1">UnivariateStatistics (ML Engine)</h1><div class="body conbody"><div class="section" id="ulp1514493205765__section_N10011_N1000E_N10001">
<p class="p">The UnivariateStatistics function calculates descriptive statistics for a set of target columns.</p></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title2" topicindex="2" topicid="qiy1514493216143" xml:lang="en-us" lang="en-us" id="qiy1514493216143">
<h2 class="title topictitle2" id="ariaid-title2">UnivariateStatistics Syntax</h2><div class="body refbody"><div class="section" id="qiy1514493216143__section_N10011_N1000E_N10001">
<h3 class="title sectiontitle">Version <span>1.2</span></h3><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM UnivariateStatistics (
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> AS InputTable
  [ OUT TABLE MomentsTableName (<var class="keyword varname">moments_table_name</var>) ]
  [ OUT TABLE BasicTableName (<var class="keyword varname">basic_table_name</var>) ]
  [ OUT TABLE QuantilesTableName (<var class="keyword varname">quantiles_table_name</var>) ]
  USING
  [ TargetColumns ('<var class="keyword varname">target_column</var>' [,...]) |
    ExcludeColumns ('<var class="keyword varname">exclude_column</var>' [,...])
  ]
  [ PartitionColumns ('<var class="keyword varname">partition_column</var>' [,...]) ]
  [ StatisticsGroups ('<var class="keyword varname">statistics_group</var>' [,...]) ]
) AS <var class="keyword varname">alias</var>;
</code></pre></div></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title3" topicindex="3" topicid="mtu1514493208025" xml:lang="en-us" lang="en-us" id="mtu1514493208025">
<h2 class="title topictitle2" id="ariaid-title3">UnivariateStatistics Syntax Elements</h2><div class="body refbody"><div class="section" id="mtu1514493208025__section_N10011_N1000E_N10001"><dl class="dl parml"><dt class="dt pt dlterm">MomentsTableName</dt><dd class="dd pd">[Required if you omit StatisticsGroups syntax element or specify <code class="ph codeph">'moments'</code>.] Specify the name for the output table that contains the moments.</dd><dt class="dt pt dlterm">BasicTableName</dt><dd class="dd pd">[Required if you omit StatisticsGroups or specify <code class="ph codeph">'basic'</code>.] Specify the name for the output table that contains the basic statistics.</dd><dt class="dt pt dlterm">QuantilesTableName</dt><dd class="dd pd">[Required if you omit StatisticsGroups or specify <code class="ph codeph">'quartiles'</code>.] Specify the name for the output table that contains the quantiles.</dd><dt class="dt pt dlterm">TargetColumns</dt><dd class="dd pd">[Optional] Specify the names of the InputTable columns for which to compute statistics.</dd><dd class="dd pd ddexpand">Default: All numerical InputTable columns</dd><dt class="dt pt dlterm">ExcludeColumns</dt><dd class="dd pd">[Optional] Specify the names of the InputTable columns to exclude from statistics calculation.</dd><dt class="dt pt dlterm">PartitionColumns</dt><dd class="dd pd">[Optional] Specify the names of the InputTable columns on which to partition the input. The function copies these columns to the output table.</dd><dd class="dd pd ddexpand">Default behavior: The function treats all rows as a single partition.</dd><dt class="dt pt dlterm">StatisticsGroups</dt><dd class="dd pd">[Optional] Specify the group or groups of statistics to calculate:
<div class="tablenoborder"><table cellpadding="4" cellspacing="0" summary="" id="mtu1514493208025__table_mgl_snr_tcb" class="table" frame="border" border="1" rules="all"><div class="caption"></div><colgroup span="1"><col style="width:33.33333333333333%" span="1"></col><col style="width:66.66666666666666%" span="1"></col></colgroup><thead class="thead" style="text-align:left;"><tr class="row"><th class="entry cellrowborder" style="vertical-align:top;" id="d25550e168" rowspan="1" colspan="1"><var class="keyword varname">statistics_group</var></th><th class="entry cellrowborder" style="vertical-align:top;" id="d25550e171" rowspan="1" colspan="1">Statistics to Calculate</th></tr></thead><tbody class="tbody"><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d25550e168" rowspan="1" colspan="1"><code class="ph codeph">'moments'</code></td><td class="entry cellrowborder" style="vertical-align:top;" headers="d25550e171" rowspan="1" colspan="1">
<ul class="ul" id="mtu1514493208025__ul_qxn_q4r_tcb">
<li class="li">Number of observations</li>
<li class="li">Sum</li>
<li class="li">Mean</li>
<li class="li">Variance</li>
<li class="li">Standard deviation</li>
<li class="li">Standard error</li>
<li class="li">Skewness</li>
<li class="li">Kurtosis</li>
<li class="li">Coefficient of variation</li>
<li class="li">Uncorrected sum of squares</li>
<li class="li">Corrected sum of squares</li></ul></td></tr><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d25550e168" rowspan="1" colspan="1"><code class="ph codeph">'basic'</code></td><td class="entry cellrowborder" style="vertical-align:top;" headers="d25550e171" rowspan="1" colspan="1">
<ul class="ul" id="mtu1514493208025__ul_b5d_hgz_tcb">
<li class="li">Number of observations</li>
<li class="li">Number of NULL values</li>
<li class="li">Number of positive, negative, and zero values</li>
<li class="li">Number of unique values</li>
<li class="li">Mode</li>
<li class="li">Median</li>
<li class="li">Mean</li>
<li class="li">Standard deviation</li>
<li class="li">Variance</li>
<li class="li">Range</li>
<li class="li">Interquartile range</li>
<li class="li">Harmonic mean</li>
<li class="li">Geometric mean</li>
<li class="li">Highest and lowest five values</li></ul></td></tr><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d25550e168" rowspan="1" colspan="1"><code class="ph codeph">'quantiles'</code></td><td class="entry cellrowborder" style="vertical-align:top;" headers="d25550e171" rowspan="1" colspan="1">
<ul class="ul" id="mtu1514493208025__ul_bxh_bpr_tcb">
<li class="li">Minimum and maximum values</li>
<li class="li">1st, 5th, 10th, 25th, 50th, 75th, 90th, 95th, and 99th percentiles</li></ul></td></tr></tbody></table></div>
<p class="p">Default behavior: The function calculates all three groups of statistics.</p></dd></dl></div></div></div></div></body></html>
