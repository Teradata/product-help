<html><head></head><body><div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="vya1507673875298" id="vya1507673875298"><h1 class="title topictitle1" id="ariaid-title1">Hypothesis-Test Mode (ML Engine)</h1><div class="body conbody">
<p class="p">In hypothesis-test mode, the function tests the hypothesis that the sample data
			comes from the specified reference distribution. The function simultaneously performs
			the specified tests and reports a p-value for each test. The null hypothesis is that the
			data are consistent with the specified distribution. Therefore, a low p-value suggests
			that the distribution is a poor fit for the data.</p></div><div class="related-links"><div class="linklistheader"><p></p><b>Related Information</b></div>
<ul class="linklist linklist relinfo"><div class="linklistmember"><a href="dev1558120780587.md#bgd1507744754025">Best-Match Mode (ML Engine)</a></div></ul></div><div class="topic reference nested1" aria-labelledby="ariaid-title2" topicindex="2" topicid="lrg1507674748665" xml:lang="en-us" lang="en-us" id="lrg1507674748665">
<h2 class="title topictitle2" id="ariaid-title2">Hypothesis-Test Mode Syntax</h2><div class="body refbody"><div class="section" id="lrg1507674748665__section_N10011_N1000E_N10001">
<p class="p">Recommended syntax depends on whether the reference distribution is continuous or
                discrete and on the sample data set. For both continuous and discrete distributions,
                there are two syntax options. Teradata recommends option 1 for large data sets
                stored across multiple nodes and option 2 for small data sets stored on a single
                node. However, performance ultimately depends on the data itself.</p></div></div><div class="topic concept nested2" aria-labelledby="ariaid-title3" topicindex="3" topicid="fcs1466004794018" xml:lang="en-us" lang="en-us" id="fcs1466004794018">
<h3 class="title topictitle3" id="ariaid-title3">Hypothesis-Test Mode Syntax (Continuous Distributions)</h3><div class="topic reference nested3" aria-labelledby="ariaid-title4" topicindex="4" topicid="msp1507675625733" xml:lang="en-us" lang="en-us" id="msp1507675625733">
<h4 class="title topictitle4" id="ariaid-title4">Multiple-Node Data Sets</h4><div class="body refbody"><div class="section" id="msp1507675625733__section_N1000E_N1000C_N10001">
<h5 class="title sectiontitle">DistributionMatchReduce version <span>1.7</span>, DistributionMatchMultiInput version 1.4</h5><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM DistributionMatchReduce (
  ON DistributionMatchMultiInput (
    ON (SELECT RANK() OVER (PARTITION BY <var class="keyword varname">col</var> [,...] 
      ORDER BY <var class="keyword varname">column</var>) AS rank, *
      FROM <var class="keyword varname">input_table</var> 
      WHERE <var class="keyword varname">column</var> IS NOT NULL
    ) AS InputTable PARTITION BY ANY
    ON (SELECT <var class="keyword varname">col</var> [,...], COUNT(*) AS group_size
      FROM <var class="keyword varname">input_table</var> 
      WHERE <var class="keyword varname">column</var> IS NOT NULL
      GROUP BY <var class="keyword varname">col</var> [,...] 
    ) AS GroupStatistics DIMENSION
    USING
    TargetColumn ('<var class="keyword varname">target_column</var>')
    [ Tests ('<var class="keyword varname">test</var>' [,...]) ]
    Distributions ('<var class="keyword varname">distribution</var>:<var class="keyword varname">parameter</var>' [,...])
  [ GroupByColumns
    ({ '<var class="keyword varname">group_column</var>' | <var class="keyword varname">group_column_range</var> }[,...]) ]
    [ MinGroupSize (<var class="keyword varname">minGroupSize</var>) ]
    [ NumCell (<var class="keyword varname">cell_size</var>) ]
  ) AS <var class="keyword varname">alias_1</var> PARTITION BY <var class="keyword varname">col</var> [,...] 
) AS <var class="keyword varname">alias_2</var>;</code></pre>
<p class="p">If your input table already includes a rank column, replace this clause:</p>
<p class="p"><code class="ph codeph">ON (SELECT RANK()...</code></p>
<p class="p">with this clause:</p>
<p class="p"><code class="ph codeph">ON SELECT * FROM <var class="keyword varname">input_table</var></code>.</p></div></div></div><div class="topic reference nested3" aria-labelledby="ariaid-title5" topicindex="5" topicid="hwf1507676337439" xml:lang="en-us" lang="en-us" id="hwf1507676337439">
<h4 class="title topictitle4" id="ariaid-title5">Single-Node Data Sets</h4><div class="body refbody"><div class="section" id="hwf1507676337439__section_N1000E_N1000C_N10001">
<h5 class="title sectiontitle">DistributionMatchReduce version <span>1.7</span>, DistributionMatchMultiInput version 1.4</h5><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM DistributionMatchReduce (
  ON DistributionMatchMultiInput (
    ON (SELECT RANK() OVER (PARTITION BY <var class="keyword varname">column</var> [,...] 
      ORDER BY <var class="keyword varname">column</var>) AS rank, *
      FROM <var class="keyword varname">input_table</var> 
      WHERE <var class="keyword varname">column</var> IS NOT NULL
    ) AS InputTable PARTITION BY <var class="keyword varname">column</var> [,...] 
    ON (SELECT <var class="keyword varname">col</var> [,...], COUNT(*) AS group_size
      FROM <var class="keyword varname">input_table</var> 
      WHERE <var class="keyword varname">column</var> IS NOT NULL <var class="keyword varname">c</var> 
      GROUP BY <var class="keyword varname">column</var> [,...] 
    ) AS GroupStatistics PARTITION BY <var class="keyword varname">column</var> [,...]
  USING
  TargetColumn ('<var class="keyword varname">target_column</var>')
  [ Tests ('<var class="keyword varname">test</var>' [,...]) ]
  Distributions ('<var class="keyword varname">distribution</var>:<var class="keyword varname">parameters</var>' [,...])
  [ GroupByColumns
    ({ '<var class="keyword varname">group_column</var>' | <var class="keyword varname">group_column_range</var> }[,...]) ]
  [ MinGroupSize (<var class="keyword varname">min_group_size</var>) ]
  [ NumCell (<var class="keyword varname">cell_size</var>) ]
  ) AS <var class="keyword varname">alias_1</var> PARTITION BY <var class="keyword varname">column</var> [,...] 
) AS <var class="keyword varname">alias_2</var>;</code></pre>
<p class="p">If your input table already includes a rank column, replace this clause:</p>
<p class="p"><code class="ph codeph">ON (SELECT RANK()...</code></p>
<p class="p">with this clause:</p>
<p class="p"><code class="ph codeph">ON SELECT * FROM <var class="keyword varname">input_table</var></code>.</p></div></div><div class="related-links"><div class="linklistheader"><p></p><b>Related Information</b></div>
<ul class="linklist linklist relinfo"><div class="linklistmember"><a href="ndv1557782188375.md">Column Specification Syntax Elements</a></div></ul></div></div></div><div class="topic concept nested2" aria-labelledby="ariaid-title6" topicindex="6" topicid="myj1466004794224" xml:lang="en-us" lang="en-us" id="myj1466004794224">
<h3 class="title topictitle3" id="ariaid-title6">Hypothesis-Test Mode Syntax (Discrete Distributions)</h3><div class="topic reference nested3" aria-labelledby="ariaid-title7" topicindex="7" topicid="eob1507677052717" xml:lang="en-us" lang="en-us" id="eob1507677052717">
<h4 class="title topictitle4" id="ariaid-title7">Multiple-Node Data Sets</h4><div class="body refbody"><div class="section" id="eob1507677052717__section_N1000E_N1000C_N10001">
<h5 class="title sectiontitle">DistributionMatchReduce version <span>1.7</span>, DistributionMatchMultiInput version 1.4</h5><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM DistributionMatchReduce (
  ON DistributionMatchMultiInput (
    ON (SELECT COUNT(1) AS counts,
      SUM(COUNT(1)) OVER (PARTITION BY <var class="keyword varname">column</var> [,...] 
        ORDER BY <var class="keyword varname">column</var>) AS rank, <var class="keyword varname">column</var> [,...] 
        FROM <var class="keyword varname">input_table</var> 
        WHERE <var class="keyword varname">column</var> IS NOT NULL
        GROUP BY <var class="keyword varname">column</var> [,...] 
    ) AS InputTable PARTITION BY ANY
    ON (SELECT <var class="keyword varname">column</var> [,...], COUNT(*) AS group_size
      FROM <var class="keyword varname">input_table</var> 
      WHERE <var class="keyword varname">column</var> IS NOT NULL
      GROUP BY <var class="keyword varname">column</var> [,...] 
    ) AS GroupStatistics DIMENSION
    USING
    TargetColumn ('<var class="keyword varname">target_column</var>')
    [ Tests ('<var class="keyword varname">test</var>' [,...]) ]
    Distributions ('<var class="keyword varname">distribution</var>:<var class="keyword varname">parameters</var>' [,...])
    [ GroupByColumns ({ '<var class="keyword varname">group_column</var>' | <var class="keyword varname">group_column_range</var> }[,...]) ]
    [ MinGroupSize (<var class="keyword varname">min_group_size</var>) ]
    [ NumCell (<var class="keyword varname">cell_size</var>) ]
  ) AS <var class="keyword varname">alias_1</var> PARTITION BY <var class="keyword varname">column</var> [,...] 
) AS <var class="keyword varname">alias_2</var>;</code></pre></div></div><div class="related-links"><div class="linklistheader"><p></p><b>Related Information</b></div>
<ul class="linklist linklist relinfo"><div class="linklistmember"><a href="ndv1557782188375.md">Column Specification Syntax Elements</a></div></ul></div></div><div class="topic reference nested3" aria-labelledby="ariaid-title8" topicindex="8" topicid="gnd1507677698297" xml:lang="en-us" lang="en-us" id="gnd1507677698297">
<h4 class="title topictitle4" id="ariaid-title8">Single-Node Data Sets and Any CvM Test</h4><div class="body refbody"><div class="section" id="gnd1507677698297__section_N1000E_N1000C_N10001">
<h5 class="title sectiontitle">DistributionMatchReduce version <span>1.7</span>, DistributionMatchMultiInput version 1.4</h5><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM DistributionMatchReduce (
  ON DistributionMatchMultiInput (
    ON (SELECT COUNT(1) AS counts,
      SUM(COUNT(1)) OVER (PARTITION BY <var class="keyword varname">column</var> [,...] 
        ORDER BY <var class="keyword varname">column</var>) AS rank, <var class="keyword varname">column</var> [,...] 
      FROM <var class="keyword varname">input_table</var> 
      WHERE <var class="keyword varname">column</var> IS NOT NULL
      GROUP BY <var class="keyword varname">column</var> [,...] 
    ) AS InputTable PARTITION BY <var class="keyword varname">column</var> [,...] ORDER BY <var class="keyword varname">column</var> 
    ON (SELECT <var class="keyword varname">column</var> [,...], COUNT(*) AS group_size
      FROM <var class="keyword varname">input_table</var> 
      WHERE <var class="keyword varname">column</var> IS NOT NULL
      GROUP BY <var class="keyword varname">column</var> [,...] 
    ) AS GroupStatistics PARTITION BY <var class="keyword varname">column</var> [,...]
    USING
    TargetColumn ('<var class="keyword varname">target_column</var>')
    [ Tests ('<var class="keyword varname">test</var>' [,...]) ]
    Distributions ('<var class="keyword varname">distribution</var>:<var class="keyword varname">parameters</var>' [,...])
    [ GroupByColumns ({ '<var class="keyword varname">group_column</var>' | '<var class="keyword varname">group_column_range</var>' [,...]) ]
    [ MinGroupSize (<var class="keyword varname">min_group_size</var>) ]
    [ NumCell (<var class="keyword varname">cell_size</var>) ]
  ) AS <var class="keyword varname">alias_1</var> PARTITION BY <var class="keyword varname">column</var> [,...] 
) AS <var class="keyword varname">alias_2</var>;</code></pre></div></div><div class="related-links"><div class="linklistheader"><p></p><b>Related Information</b></div>
<ul class="linklist linklist relinfo"><div class="linklistmember"><a href="ndv1557782188375.md">Column Specification Syntax Elements</a></div></ul></div></div></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title9" topicindex="9" topicid="wwg1507678428399" xml:lang="en-us" lang="en-us" id="wwg1507678428399">
<h2 class="title topictitle2" id="ariaid-title9">Hypothesis-Test Mode Syntax Elements</h2><div class="body refbody"><div class="section" id="wwg1507678428399__section_N10011_N1000E_N10001"><dl class="dl parml"><dt class="dt pt dlterm">TargetColumn</dt><dd class="dd pd">Specify the name of the InputTable column that contains the values of the sample data set.</dd><dt class="dt pt dlterm">Tests</dt><dd class="dd pd">[Optional] Specify one to four tests to perform:
<div class="tablenoborder"><table cellpadding="4" cellspacing="0" summary="" id="wwg1507678428399__table_f4y_p4y_fdb" class="table" frame="border" border="1" rules="all"><div class="caption"></div><colgroup span="1"><col style="width:50%" span="1"></col><col style="width:50%" span="1"></col></colgroup><thead class="thead" style="text-align:left;"><tr class="row"><th class="entry cellrowborder" style="vertical-align:top;" id="d36949e577" rowspan="1" colspan="1"><var class="keyword varname">test</var></th><th class="entry cellrowborder" style="vertical-align:top;" id="d36949e580" rowspan="1" colspan="1">Description</th></tr></thead><tbody class="tbody"><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d36949e577" rowspan="1" colspan="1"><code class="ph codeph">'KS'</code></td><td class="entry cellrowborder" style="vertical-align:top;" headers="d36949e580" rowspan="1" colspan="1">Kolmogorov-Smirnov test.</td></tr><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d36949e577" rowspan="1" colspan="1"><code class="ph codeph">'CvM'</code></td><td class="entry cellrowborder" style="vertical-align:top;" headers="d36949e580" rowspan="1" colspan="1">Cramér-von Mises criterion.</td></tr><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d36949e577" rowspan="1" colspan="1"><code class="ph codeph">'AD'</code></td><td class="entry cellrowborder" style="vertical-align:top;" headers="d36949e580" rowspan="1" colspan="1">Anderson-Darling test.</td></tr><tr class="row"><td class="entry cellrowborder" style="vertical-align:top;" headers="d36949e577" rowspan="1" colspan="1"><code class="ph codeph">'CHISQ'</code></td><td class="entry cellrowborder" style="vertical-align:top;" headers="d36949e580" rowspan="1" colspan="1">Pearson's Chi-squared test.</td></tr></tbody></table></div></dd><dd class="dd pd ddexpand">Default: All tests</dd><dt class="dt pt dlterm">Distributions</dt><dd class="dd pd">Specify the reference distributions and their parameters. Either all distributions must be continuous or all must be discrete.</dd><dd class="dd pd ddexpand"><div class="tablenoborder"><table cellpadding="4" cellspacing="0" summary="" id="wwg1507678428399__table_N100BE_N1000C_N10001" class="table" frame="border" border="1" rules="all"><div class="caption"><span><span>Continuous Distributions and Parameters</span></span></div><colgroup span="1"><col style="width:33.33333333333333%" span="1"></col><col style="width:66.66666666666666%" span="1"></col></colgroup><thead class="thead" style="text-align:left;"><tr class="row"><th class="entry nocellnorowborder" style="vertical-align:top;" id="d36949e624" rowspan="1" colspan="1"><var class="keyword varname">distribution</var>:<var class="keyword varname">parameters</var></th><th class="entry cell-norowborder" style="vertical-align:top;" id="d36949e630" rowspan="1" colspan="1">parameter Descriptions</th></tr></thead><tbody class="tbody"><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d36949e624" rowspan="1" colspan="1">BETA:α,β</td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d36949e630" rowspan="1" colspan="1">α > 0 is the first shape parameter.
<p class="p">β > 0 is the second shape parameter.</p></td></tr><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d36949e624" rowspan="1" colspan="1">CAUCHY:x,θ</td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d36949e630" rowspan="1" colspan="1">x, a DOUBLE PRECISION value, is the median parameter.
<p class="p">θ > 0 is the scale parameter.</p></td></tr><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d36949e624" rowspan="1" colspan="1">CHISQ:k</td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d36949e630" rowspan="1" colspan="1">k, a positive INTEGER, is the degree of freedom.</td></tr><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d36949e624" rowspan="1" colspan="1">EXPONENTIAL:θ</td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d36949e630" rowspan="1" colspan="1">θ > 0 is the mean parameter, which is the inverse rate.</td></tr><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d36949e624" rowspan="1" colspan="1">F:d<span><sub>1</sub></span>,d<span><sub>2</sub></span></td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d36949e630" rowspan="1" colspan="1">d<span><sub>1</sub></span> > 0 and d<span><sub>2</sub></span> > 0 are degrees of freedom.</td></tr><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d36949e624" rowspan="1" colspan="1">GAMMA:k,θ</td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d36949e630" rowspan="1" colspan="1">k > 0 is the shape parameter.
<p class="p">θ > 0 is the scale parameter.</p></td></tr><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d36949e624" rowspan="1" colspan="1">LOGNORMAL:μ,σ</td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d36949e630" rowspan="1" colspan="1">μ, a DOUBLE PRECISION value, is the mean.
<p class="p">σ > 0 is the standard deviation.</p></td></tr><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d36949e624" rowspan="1" colspan="1">NORMAL:μ,σ</td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d36949e630" rowspan="1" colspan="1">μ, a DOUBLE PRECISION value, is the mean.
<p class="p">σ > 0 is the standard deviation.</p></td></tr><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d36949e624" rowspan="1" colspan="1">T:k</td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d36949e630" rowspan="1" colspan="1">k, a positive INTEGER, is the degree of freedom.</td></tr><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d36949e624" rowspan="1" colspan="1">TRIANGULAR:a,c,b</td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d36949e630" rowspan="1" colspan="1">a <= c <= b &amp;&amp; a < b, where a is the lower limit of this distribution (inclusive), b is the upper limit of this distribution (inclusive), and c is the mode of this distribution.</td></tr><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d36949e624" rowspan="1" colspan="1">UNIFORMCONTINUOUS:a,b</td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d36949e630" rowspan="1" colspan="1">a < b, where a is the lower bound of this distribution (inclusive) and b is the upper bound of this distribution (exclusive).</td></tr><tr class="row"><td class="entry row-nocellborder" style="vertical-align:top;" headers="d36949e624" rowspan="1" colspan="1">WEIBULL:α,β</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d36949e630" rowspan="1" colspan="1">α > 0 is the shape parameter.
<p class="p">β > 0 is the scale parameter.</p>
<p class="p">The function uses the two-parameter form of the distribution defined by the Weibull Distribution, <a class="xref" href="http://mathworld.wolfram.com/WeibullDistribution.html" target="_blank" title="" shape="rect">http://mathworld.wolfram.com/WeibullDistribution.html</a>, equations (1) and (2).</p></td></tr></tbody></table></div></dd><dd class="dd pd ddexpand"><div class="tablenoborder"><table cellpadding="4" cellspacing="0" summary="" id="wwg1507678428399__table_N10182_N1000C_N10001" class="table" frame="border" border="1" rules="all"><div class="caption"><span>Discrete Distributions and Parameters</span></div><colgroup span="1"><col style="width:33.33333333333333%" span="1"></col><col style="width:66.66666666666666%" span="1"></col></colgroup><thead class="thead" style="text-align:left;"><tr class="row"><th class="entry nocellnorowborder" style="vertical-align:top;" id="d36949e732" rowspan="1" colspan="1"><var class="keyword varname">distribution</var>:<var class="keyword varname">parameters</var></th><th class="entry cell-norowborder" style="vertical-align:top;" id="d36949e738" rowspan="1" colspan="1">parameter Descriptions</th></tr></thead><tbody class="tbody"><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d36949e732" rowspan="1" colspan="1">BINOMIAL:n,p</td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d36949e738" rowspan="1" colspan="1">n, a positive INTEGER, is the number of trials.
<p class="p">p, in [0,1], is the success probability in each trial.</p></td></tr><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d36949e732" rowspan="1" colspan="1">GEOMETRIC:p</td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d36949e738" rowspan="1" colspan="1">p, in [0,1], is the success probability in each trial.</td></tr><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d36949e732" rowspan="1" colspan="1">NEGATIVEBINOMIAL:r,p</td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d36949e738" rowspan="1" colspan="1">r, a positive INTEGER, is the number of successes until the function stops the tests.
<p class="p">p, in [0,1], is the success probability in each trial.</p>
<p class="p">The function represents the distribution of the number of failures before r successes occur.</p></td></tr><tr class="row"><td class="entry nocellnorowborder" style="vertical-align:top;" headers="d36949e732" rowspan="1" colspan="1">POISSON:λ</td><td class="entry cell-norowborder" style="vertical-align:top;" headers="d36949e738" rowspan="1" colspan="1">λ > 0 is the rate parameter.</td></tr><tr class="row"><td class="entry row-nocellborder" style="vertical-align:top;" headers="d36949e732" rowspan="1" colspan="1">UNIFORMDISCRETE:a,b</td><td class="entry cellrowborder" style="vertical-align:top;" headers="d36949e738" rowspan="1" colspan="1">a < b, where a is the lower bound of this distribution (inclusive) and b is the upper bound of this distribution (exclusive). Both a and b are INTEGER values.</td></tr></tbody></table></div><div class="p">For discrete distributions:
<ul class="ul" id="wwg1507678428399__ul_xt2_4gx_kx">
<li class="li">BINOMIAL, GEOMETRIC, NEGATIVEBINOMIAL, and POISSON distributions are on N={0,1,2,...}.</li>
<li class="li">UNIFORMDISCRETE distribution is on events, which are represented by integers.</li></ul></div></dd><dt class="dt pt dlterm">GroupByColumns</dt><dd class="dd pd">[Optional] Specify the names of the InputTable columns that contain the group identifications over which to run the test. The function can run multiple tests for different partitions of the data in parallel. If you omit this syntax element, specify PARTITION BY 1 and omit the GROUP BY clause in the second ON clause.</dd><dt class="dt pt dlterm">MinGroupSize</dt><dd class="dd pd">[Optional] Specify the minimum group size. The function ignores groups smaller than the minimum size when calculating statistics.</dd><dd class="dd pd ddexpand">Default: 50</dd><dt class="dt pt dlterm">NumCell</dt><dd class="dd pd">[Optional] Specify the number of cells to make discrete in a continuous distribution. The cell_size must be greater than 3 if <var class="keyword varname">distribution</var> is NORMAL; otherwise, it must be greater than 1. The quotient <var class="keyword varname">min_group_size</var>/<var class="keyword varname">cell_size</var> cannot be less than 5.</dd><dd class="dd pd ddexpand">If you specify NumCell, you must specify <code class="ph codeph">'CHISQ'</code> in the Tests syntax element.</dd><dd class="dd pd ddexpand">Default: 10</dd></dl></div></div></div></div></body></html>
