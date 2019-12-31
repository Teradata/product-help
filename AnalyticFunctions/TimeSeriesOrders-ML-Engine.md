<div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="fwf1507221810968" id="fwf1507221810968"><h1 class="title topictitle1" id="ariaid-title1">TimeSeriesOrders (ML Engine)</h1><div class="body conbody"><div class="p">The TimeSeriesOrders function automatically determines the following for nonseasonal,
			univariate time series:
<ul class="ul" id="fwf1507221810968__ul_zdh_4pq_r1b">
<li class="li">The orders (<var class="keyword varname">p</var>, <var class="keyword varname">d</var>, <var class="keyword varname">q</var>)
<p class="p">For descriptions of these orders, see the information about nonseasonal ARIMA models in <a class="xref" href="https://www.otexts.org/fpp/8" target="_blank" title="" shape="rect">https://www.otexts.org/fpp/8</a>.</p></li>
<li class="li">Whether to include a nonzero constant term (mean) and an explicit dependence on
					time (a drift term)</li></ul></div>
<p class="p">If a time series has a seasonal component, the function reports <var class="keyword varname">p</var>, <var class="keyword varname">d</var>, and <var class="keyword varname">q</var>, but does not calculate or report seasonal orders <var class="keyword varname">sp</var>, <var class="keyword varname">sd</var>, and <var class="keyword varname">sq</var>. (For descriptions of the seasonal orders, see the information about seasonal ARIMA models in <a class="xref" href="https://www.otexts.org/fpp/8" target="_blank" title="" shape="rect">https://www.otexts.org/fpp/8</a>.) </p>
<p class="p">You can use the TimeSeriesOrders output as the orders table of the <a href="lla1558463669510.md#zsj1506019075317">ARIMA (ML Engine)</a> or <a href="lnd1558463317081.md#klg1507052716326">VARMAX (ML Engine)</a> function.</p></div><div class="topic reference nested1" aria-labelledby="ariaid-title2" topicindex="2" topicid="tmg1507221974506" xml:lang="en-us" lang="en-us" id="tmg1507221974506">
<h2 class="title topictitle2" id="ariaid-title2">TimeSeriesOrders Syntax</h2><div class="body refbody"><div class="section" id="tmg1507221974506__section_N10014_N10011_N10001">
<h3 class="title sectiontitle">Version <span>1.3</span></h3><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM TimeSeriesOrders (   
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> AS InputTable
    PARTITION BY { 1 | <var class="keyword varname">partition_column</var> [,...] } ORDER BY <var class="keyword varname">time_column</var> ASC [,...]
  USING      
  ResponseColumn ('<var class="keyword varname">response_column</var>')
  [ PartitionColumns ('<var class="keyword varname">partition_column</var>' [,...]) ]
) AS <var class="keyword varname">alias</var>;</code></pre>
<p class="p">In the ORDER BY clause, put ASC after each <var class="keyword varname">time_column</var>.</p></div></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title3" topicindex="3" topicid="beo1507222823837" xml:lang="en-us" lang="en-us" id="beo1507222823837">
<h2 class="title topictitle2" id="ariaid-title3">TimeSeriesOrders Syntax Elements</h2><div class="body refbody"><div class="section" id="beo1507222823837__section_N10014_N10011_N10001"><dl class="dl parml"><dt class="dt pt dlterm">ResponseColumn</dt><dd class="dd pd">Specify the name of the <var class="keyword varname">input_table</var> column that contains the response variable.</dd><dt class="dt pt dlterm">PartitionColumns</dt><dd class="dd pd">[Required if you partition by columns, disallowed otherwise.] Specify the partition columns to pass to the output, which must be the same as those in the PARTITION BY clause.</dd></dl></div></div></div></div>
