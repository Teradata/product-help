<html><head></head><body><div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="bgd1507744754025" id="bgd1507744754025"><h1 class="title topictitle1" id="ariaid-title1">Best-Match Mode (ML Engine)</h1><div class="body conbody">
<p class="p">In best-match mode, the function uses the result of hypothesis-test mode to find the distribution that best matches the sample data. For each specified test, the function reports the best match, identifying the distribution type and parameters.</p></div><div class="related-links"><div class="linklistheader"><p></p><b>Related Information</b></div>
<ul class="linklist linklist relinfo"><div class="linklistmember"><a href="rov1558120764457.md#vya1507673875298">Hypothesis-Test Mode (ML Engine)</a></div></ul></div><div class="topic reference nested1" aria-labelledby="ariaid-title2" topicindex="2" topicid="zup1507745372496" xml:lang="en-us" lang="en-us" id="zup1507745372496">
<h2 class="title topictitle2" id="ariaid-title2">Best-Match Mode Syntax (DOUBLE PRECISION Input)</h2><div class="body refbody"><div class="section" id="zup1507745372496__section_N1000E_N1000C_N10001">
<h3 class="title sectiontitle">DistributionMatchReduce version <span>1.7</span>, DistributionMatchMultiInput version 1.4</h3><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM DistributionMatchReduce (
  ON DistributionMatchMultiInput (
    ON (SELECT RANK() OVER (PARTITION BY <var class="keyword varname">column</var> [,...]
      ORDER BY <var class="keyword varname">column</var>) AS rank, *
      FROM <var class="keyword varname">input_table</var> WHERE <var class="keyword varname">column</var> IS NOT NULL)
      AS InputTable PARTITION BY ANY
    ON (SELECT <var class="keyword varname">column</var>[,...]
      COUNT(*) AS group_size,
      AVG (<var class="keyword varname">column</var>) AS mean,
      STDDEV (<var class="keyword varname">column</var>) AS sd,
      CASE
        WHEN MIN (<var class="keyword varname">column</var>) > 0 THEN AVG (LN (
          CASE
            WHEN <var class="keyword varname">column</var> > 0 THEN <var class="keyword varname">column</var> 
            ELSE 1
          END)
        )
        ELSE 0
      END AS mean_of_ln,
      CASE
        WHEN MIN (<var class="keyword varname">column</var>) > 0 THEN STDDEV (LN (
          CASE
            WHEN <var class="keyword varname">column</var> > 0 THEN <var class="keyword varname">column</var> 
            ELSE 1
          END)
        )
        ELSE -1
      END AS sd_of_ln,
      Max (<var class="keyword varname">column</var>) AS maximum,
      MIN (<var class="keyword varname">column</var>) AS minimum
      FROM <var class="keyword varname">input_table</var> 
      WHERE <var class="keyword varname">column</var> IS NOT NULL
      GROUP BY <var class="keyword varname">column</var>[,...]
    ) AS GroupStatistics DIMENSION
    USING
    TargetColumn ('<var class="keyword varname">target_column</var>')
    [ Tests ('<var class="keyword varname">test</var>' [,...]) ]
    [ Distributions ('<var class="keyword varname">distribution1</var>:<var class="keyword varname">parameter1</var>',...) ]
    [ GroupByColumns
    ({ '<var class="keyword varname">group_column</var>' | <var class="keyword varname">group_column_range</var> }[,...]) ]
    MinGroupSize (<var class="keyword varname">minGroupSize</var>)
    [ NumCell (<var class="keyword varname">cell_Size</var>) ]
  ) AS <var class="keyword varname">alias_1</var> PARTITION BY <var class="keyword varname">column</var>[,...]   
  [ USING NumTopMatches ('<var class="keyword varname">num_top_matches</var>') ]
) AS <var class="keyword varname">alias_2</var>;</code></pre>
<p class="p">For continuous distributions, if your input table already includes a rank column, replace this clause:</p>
<p class="p"><code class="ph codeph">ON (SELECT RANK()...</code></p>
<p class="p">with this clause:</p>
<p class="p"><code class="ph codeph">ON SELECT * FROM <var class="keyword varname">input_table</var></code>.</p></div></div><div class="related-links"><div class="linklistheader"><p></p><b>Related Information</b></div>
<ul class="linklist linklist relinfo"><div class="linklistmember"><a href="ndv1557782188375.md">Column Specification Syntax Elements</a></div></ul></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title3" topicindex="3" topicid="idv1507745677833" xml:lang="en-us" lang="en-us" id="idv1507745677833">
<h2 class="title topictitle2" id="ariaid-title3">Best-Match Mode Syntax (INTEGER Input)</h2><div class="body refbody"><div class="section" id="idv1507745677833__section_N1000E_N1000C_N10001">
<h3 class="title sectiontitle">DistributionMatchReduce version <span>1.7</span>, DistributionMatchMultiInput version 1.4</h3><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM DistributionMatchReduce (
  ON DistributionMatchMultiInput (
    ON (SELECT COUNT(1) AS counts,
      SUM(COUNT(1)) OVER (PARTITION BY <var class="keyword varname">column</var>[,...]
      ORDER BY <var class="keyword varname">column</var>) AS rank,
      <var class="keyword varname">column</var> [,...], <var class="keyword varname">column</var> 
      FROM <var class="keyword varname">input_table</var> 
      WHERE <var class="keyword varname">column</var> IS NOT NULL
      GROUP BY <var class="keyword varname">column</var> [,...], <var class="keyword varname">column</var> 
    ) AS InputTable PARTITION BY ANY
    ON (SELECT <var class="keyword varname">column</var> [,...],
      COUNT(*) AS group_size,
      AVG (<var class="keyword varname">column</var>) AS mean,
      STDDEV (<var class="keyword varname">column</var>) AS sd,
      MAX (<var class="keyword varname">column</var>) AS maximum,
      MIN (<var class="keyword varname">column</var>) AS minimum
      FROM <var class="keyword varname">input_table</var> 
      WHERE <var class="keyword varname">column</var> IS NOT NULL
      GROUP BY <var class="keyword varname">column</var>[,...]
    ) AS GroupStatistics DIMENSION
    USING
    TargetColumn ('<var class="keyword varname">target_column</var>')
    [ Tests ('<var class="keyword varname">test</var>' [,...]) ]
    [ Distributions ('<var class="keyword varname">distribution1</var>:<var class="keyword varname">parameter1</var>' [,... ]) ]
    [ GroupByColumns
    ({ '<var class="keyword varname">group_column</var>' | <var class="keyword varname">group_column_range</var> }[,...]) ]
    MinGroupSize (<var class="keyword varname">minGroupSize</var>)
    [ NumCell (<var class="keyword varname">cell_Size</var>) ]
  ) AS <var class="keyword varname">alias_1</var> PARTITION BY <var class="keyword varname">column</var>[,...]
  [ USING NumTopMatches ('<var class="keyword varname">num_top_matches</var>') ]
) AS <var class="keyword varname">alias_2</var>;</code></pre>
<p class="p">For continuous distributions, if your input table already includes a rank column, replace this clause:</p>
<p class="p"><code class="ph codeph">ON (SELECT RANK()...</code></p>
<p class="p">with this clause:</p>
<p class="p"><code class="ph codeph">ON SELECT * FROM <var class="keyword varname">input_table</var></code>.</p></div></div><div class="related-links"><div class="linklistheader"><p></p><b>Related Information</b></div>
<ul class="linklist linklist relinfo"><div class="linklistmember"><a href="ndv1557782188375.md">Column Specification Syntax Elements</a></div></ul></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title4" topicindex="4" topicid="cbp1507745873055" xml:lang="en-us" lang="en-us" id="cbp1507745873055">
<h2 class="title topictitle2" id="ariaid-title4">Best-Match Mode Syntax Elements</h2><div class="body refbody"><div class="section" id="cbp1507745873055__section_N10011_N1000E_N10001"><dl class="dl parml"><dt class="dt pt dlterm">TargetColumn</dt><dd class="dd pd">Specify the name of the InputTable column that contains the values of the sample data set.</dd><dt class="dt pt dlterm">Tests</dt><dd class="dd pd">[Optional] Specify one to three tests to perform:
<div class="tablenoborder"><table cellpadding="4" cellspacing="0" summary="" id="cbp1507745873055__table_dtn_bpy_fdb" class="table" frame="border" border="1" rules="all"><div class="caption"></div><colgroup span="1"><col style="width:50%" span="1"></col><col style="width:50%" span="1"></col></colgroup><thead class="thead" style="text-align:left;"><tr class="row"><th class="entry cellrowborder" style="vertical-align:top;" id="d12601e385" rowspan="1" colspan="1"><var class="keyword varname">test</var></th><th class="entry cellrowborder" style="vertical-align:top;" id="d12601e388" rowspan="1" colspan="1">Description</th></tr></thead><tbody class="tbody"><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d12601e385" rowspan="1" colspan="1"><code class="ph codeph">'KS'</code></td><td class="entry cellrowborder" style="vertical-align:top;" headers="d12601e388" rowspan="1" colspan="1">Kolmogorov-Smirnov test.</td></tr><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d12601e385" rowspan="1" colspan="1"><code class="ph codeph">'AD'</code></td><td class="entry cellrowborder" style="vertical-align:top;" headers="d12601e388" rowspan="1" colspan="1">Anderson-Darling test.</td></tr><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d12601e385" rowspan="1" colspan="1"><code class="ph codeph">'CHISQ'</code></td><td class="entry cellrowborder" style="vertical-align:top;" headers="d12601e388" rowspan="1" colspan="1">Pearson's Chi-squared test.</td></tr></tbody></table></div></dd><dd class="dd pd ddexpand">Default: All tests</dd><dt class="dt pt dlterm">Distributions</dt><dd class="dd pd">[Optional] Specify the reference distributions (which must be continuous) and their parameters. The possible <var class="keyword varname">distribution</var> and <var class="keyword varname">parameters</var> values for continuous distributions are in the table, <span>Continuous Distributions and Parameters</span>, in <a href="rov1558120764457.md#wwg1507678428399">Hypothesis-Test Mode Syntax Elements</a>.</dd><dd class="dd pd ddexpand">Default: All of these distributions:
<ul class="ul" id="cbp1507745873055__ul_r4k_zlx_kx">
<li class="li">Beta</li>
<li class="li">Cauchy</li>
<li class="li">CHISQ</li>
<li class="li">Exponential</li>
<li class="li">F</li>
<li class="li">Gamma</li>
<li class="li">Lognormal</li>
<li class="li">Normal</li>
<li class="li">T</li>
<li class="li">Triangular</li>
<li class="li">Uniformcontinuous</li>
<li class="li">Weibull</li></ul></dd><dt class="dt pt dlterm">GroupByColumns</dt><dd class="dd pd">[Optional] Specify the names of the InputTable columns that contain the group identifications over which to run the test. The function can run multiple tests for different partitions of the data in parallel. If you omit this syntax element, specify PARTITION BY 1 and omit the GROUP BY clause in the second ON clause.</dd><dt class="dt pt dlterm">MinGroupSize</dt><dd class="dd pd">[Optional] Specify the minimum group size. The function ignores groups smaller than the minimum size when calculating statistics.</dd><dd class="dd pd ddexpand">Default: 50</dd><dt class="dt pt dlterm">NumCell</dt><dd class="dd pd">[Optional] Specify the number of cells to make discrete in a continuous distribution. The <var class="keyword varname">cell_size</var> must be greater than 3 if <var class="keyword varname">distribution</var> is NORMAL; otherwise, it must be greater than 1. The quotient <var class="keyword varname">min_group_size</var>/<var class="keyword varname">cell_size</var> cannot be less than 5.</dd><dd class="dd pd ddexpand">If you specify NumCell, you must specify <code class="ph codeph">'CHISQ'</code> in the Tests syntax element.</dd><dd class="dd pd ddexpand">Default: 10</dd><dt class="dt pt dlterm">NumTopMatches</dt><dd class="dd pd">[Optional] Specify the number of the top matching distributions for the function to output.</dd><dd class="dd pd ddexpand">Default: 1</dd></dl></div></div></div></div></body></html>
