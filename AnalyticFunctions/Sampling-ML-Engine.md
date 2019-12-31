<div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="nfy1507741780921" id="nfy1507741780921"><h1 class="title topictitle1" id="ariaid-title1">Sampling (ML Engine)</h1><div class="body conbody">
<p class="p">The Sampling function draws rows randomly from the input table.</p>
<p class="p">The function offers two sampling schemes:</p>
<ul class="ul" id="nfy1507741780921__ul_zjs_bjs_p1b">
<li class="li">A simple Bernoulli (Binomial) sampling on a row-by-row basis with given sample rates</li>
<li class="li">Sampling without replacement that selects a given number of rows</li></ul>
<p class="p">Sampling can be either unconditional or conditional. <dfn class="term">Unconditional sampling</dfn> applies to all input data and always uses the same random number generator. <dfn class="term">Conditional sampling</dfn> applies only to input data that meets specified conditions and uses a different random number generator for each condition.</p><div class="note note" id="nfy1507741780921__note_N1002A_N1000E_N1000C_N10001"><span><b>Note</b></span><div class="notebody">The Sampling function does not guarantee the exact sizes of samples. If each sample must have an exact number of rows, use the <a href="erv1549378867990.md#vkk1507737806782">RandomSample (ML Engine)</a> function.</div></div></div><div class="related-links"><div class="linklistheader"><p></p><b>Related Information</b></div>
<ul class="linklist linklist relinfo"><div class="linklistmember"><a href="qym1549987102806.md">Nondeterministic Results and UniqueID Syntax Element</a></div></ul></div><div class="topic concept nested1" aria-labelledby="ariaid-title2" topicindex="2" topicid="ojd1523287976538" xml:lang="en-us" lang="en-us" id="ojd1523287976538">
<h2 class="title topictitle2" id="ariaid-title2">Sampling Syntax</h2><div class="topic reference nested2" aria-labelledby="ariaid-title3" topicindex="3" topicid="xjj1507743837669" xml:lang="en-us" lang="en-us" id="xjj1507743837669">
<h3 class="title topictitle3" id="ariaid-title3">Unconditional Sampling, Single Sample Rate</h3><div class="body refbody"><div class="section" id="xjj1507743837669__section_N1000E_N1000C_N10001">
<h4 class="title sectiontitle">Version 1.5</h4><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM Sampling (
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> PARTITION BY { ANY | <var class="keyword varname">key</var> }
  USING
  SampleFraction (<var class="keyword varname">fraction</var>)
  [ Seed (<var class="keyword varname">seed</var>) ]
) AS <var class="keyword varname">alias</var>;</code></pre></div></div></div><div class="topic reference nested2" aria-labelledby="ariaid-title4" topicindex="4" topicid="uar1507743911852" xml:lang="en-us" lang="en-us" id="uar1507743911852">
<h3 class="title topictitle3" id="ariaid-title4">Unconditional Sampling, Approximate Sample Size</h3><div class="body refbody"><div class="section" id="uar1507743911852__section_N1000E_N1000C_N10001">
<h4 class="title sectiontitle">Version 1.5</h4><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM Sampling (
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> AS InputTable PARTITION BY { ANY | <var class="keyword varname">key</var> }
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> AS SummaryTable DIMENSION
  USING
  ApproxSampleSize (<var class="keyword varname">size</var>)
  [ Seed (<var class="keyword varname">seed</var>) ]
) AS <var class="keyword varname">alias</var>;</code></pre></div></div></div><div class="topic reference nested2" aria-labelledby="ariaid-title5" topicindex="5" topicid="suj1507743987256" xml:lang="en-us" lang="en-us" id="suj1507743987256">
<h3 class="title topictitle3" id="ariaid-title5">Conditional Simple Sampling, Single Sample Rate</h3><div class="body refbody"><div class="section" id="suj1507743987256__section_N1000E_N1000C_N10001">
<h4 class="title sectiontitle">Version 1.5</h4><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM Sampling (
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> PARTITION BY { ANY | <var class="keyword varname">key</var> }
  USING
  StratumColumn ('<var class="keyword varname">stratum_column</var>')
  Strata ('<var class="keyword varname">condition</var>' [,...])
  SampleFraction (<var class="keyword varname">fraction</var>)
  [ Seed (<var class="keyword varname">seed</var>) ]
) AS <var class="keyword varname">alias</var>;</code></pre></div></div></div><div class="topic reference nested2" aria-labelledby="ariaid-title6" topicindex="6" topicid="jlu1507747224405" xml:lang="en-us" lang="en-us" id="jlu1507747224405">
<h3 class="title topictitle3" id="ariaid-title6">Conditional Sampling, Variable Sample Rates</h3><div class="body refbody"><div class="section" id="jlu1507747224405__section_N1000E_N1000C_N10001">
<h4 class="title sectiontitle">Version 1.5</h4><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM Sampling (
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> PARTITION BY { ANY | <var class="keyword varname">key</var> }
  USING
  StratumColumn ('<var class="keyword varname">stratum_column</var>')
  Strata ('<var class="keyword varname">condition</var>' [,...])
  SampleFraction (<var class="keyword varname">fraction</var> [,...])
  [ Seed (<var class="keyword varname">seed</var>) ]
) AS <var class="keyword varname">alias</var>;</code></pre></div></div></div><div class="topic reference nested2" aria-labelledby="ariaid-title7" topicindex="7" topicid="pgz1507760498915" xml:lang="en-us" lang="en-us" id="pgz1507760498915">
<h3 class="title topictitle3" id="ariaid-title7">Conditional Sampling, Approximate Sample Size</h3><div class="body refbody"><div class="section" id="pgz1507760498915__section_N10011_N1000E_N10001">
<h4 class="title sectiontitle">Version 1.5</h4><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM Sampling (
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> AS InputTable PARTITION BY { ANY | <var class="keyword varname">key</var> }
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> AS SummaryTable DIMENSION
  USING
  StratumColumn ('<var class="keyword varname">stratum_column</var>')
  Strata ('<var class="keyword varname">condition</var>' [,...])
  ApproxSampleSize (<var class="keyword varname">total_sample_size</var>)
  [ Seed (<var class="keyword varname">seed</var>) ]
) AS <var class="keyword varname">alias</var>;</code></pre></div></div></div><div class="topic reference nested2" aria-labelledby="ariaid-title8" topicindex="8" topicid="ijr1507760572667" xml:lang="en-us" lang="en-us" id="ijr1507760572667">
<h3 class="title topictitle3" id="ariaid-title8">Conditional Sampling, Variable Approximate Sample Sizes</h3><div class="body refbody"><div class="section" id="ijr1507760572667__section_N1000E_N1000C_N10001">
<h4 class="title sectiontitle">Version 1.5</h4><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM Sampling (
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> AS InputTable PARTITION BY ANY { ANY | <var class="keyword varname">key</var> }
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> AS SummaryTable DIMENSION
  USING
  StratumColumn ('<var class="keyword varname">stratum_column</var>')
  Strata ('<var class="keyword varname">condition</var>' [,...])
  ApproxSampleSize (<var class="keyword varname">size</var> [,...])
  [ Seed (<var class="keyword varname">seed</var>) ]
) AS <var class="keyword varname">alias</var>;</code></pre></div></div></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title9" topicindex="9" topicid="pgs1507741861051" xml:lang="en-us" lang="en-us" id="pgs1507741861051">
<h2 class="title topictitle2" id="ariaid-title9">Sampling Syntax Elements</h2><div class="body refbody"><div class="section" id="pgs1507741861051__section_N10011_N1000E_N10001"><dl class="dl parml"><dt class="dt pt dlterm">SampleFraction</dt><dd class="dd pd">Specify one or more fractions to use in sampling the data. (Syntax options that do not use SampleFraction require ApproxSampleSize.)</dd><dd class="dd pd ddexpand">If you specify only one <var class="keyword varname">fraction</var>, then the function uses <var class="keyword varname">fraction</var> for all strata defined by the sample conditions.</dd><dd class="dd pd ddexpand">If you specify more than one <var class="keyword varname">fraction</var>, then the function uses each <var class="keyword varname">fraction</var> for sampling a particular stratum defined by the condition syntax elements.</dd><dd class="dd pd ddexpand">For conditional sampling with variable sample sizes, specify one <var class="keyword varname">fraction</var> for each condition that you specify with the Strata syntax element.</dd><dt class="dt pt dlterm">Seed</dt><dd class="dd pd">[Optional] Specify the random seed the algorithm uses for repeatable results. The <var class="keyword varname">seed</var> must be a LONG value.<div class="note note" id="pgs1507741861051__note_N10071_N10068_N10061_N1002C_N10028_N10024_N10001"><span><b>Note</b></span><div class="notebody"> For repeatable results, use both the Seed and UniqueID syntax elements. For more information, see <a href="qym1549987102806.md">Nondeterministic Results and UniqueID Syntax Element</a>.</div></div></dd><dd class="dd pd ddexpand">Default: 0</dd><dt class="dt pt dlterm">ApproxSampleSize</dt><dd class="dd pd">[Optional] Specify one or more approximate sample sizes to use in sampling the data. (Syntax options that do not use ApproxSampleSize require SampleFraction.) Each sample size is approximate because the function maps the size to the sample fractions and then creates the sample data.</dd><dd class="dd pd ddexpand">If you specify only one size, it represents the total sample size for the entire population. If you also specify the Strata syntax element, the function proportionally creates sample units for each stratum.</dd><dd class="dd pd ddexpand">If you specify more than one <var class="keyword varname">size</var>, then each <var class="keyword varname">size</var> corresponds to a stratum, and the function uses each <var class="keyword varname">size</var> to create sample units for the corresponding stratum.</dd><dd class="dd pd ddexpand">For conditional sampling with variable approximate sample sizes, specify one size for each condition that you specify with the Strata syntax element.</dd><dt class="dt pt dlterm">StratumColumn</dt><dd class="dd pd">[Required for conditional sampling, disallowed otherwise.] Specify the name of the column that contains the sample conditions. If the function has only InputTable, <var class="keyword varname">stratum_column</var> is in InputTable. If the function has both InputTable and SummaryTable, <var class="keyword varname">stratum_column</var> is in SummaryTable.</dd><dt class="dt pt dlterm">Strata</dt><dd class="dd pd">[Required with StratumColumn.] Specify the sample conditions that appear in the <var class="keyword varname">stratum_column</var>. If Strata specifies a <var class="keyword varname">condition</var> that does not appear in <var class="keyword varname">stratum_column</var>, the function issues an error message.</dd></dl></div></div></div></div>
