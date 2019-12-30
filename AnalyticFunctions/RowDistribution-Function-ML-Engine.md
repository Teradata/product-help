<html><head></head><body><div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="ddn1563998292313" id="ddn1563998292313"><h1 class="title topictitle1" id="ariaid-title1">RowDistribution Function (ML Engine)</h1><div class="body refbody"><div class="section" id="ddn1563998292313__section_N10024_N10021_N10001">
<p class="p">The primary purpose of the RowDistribution function is to examine the distribution of data across vworkers. Skewed data distribution can decrease the performance (calculation speed) of some analytic functions. For more information, and instructions for interpreting the results of this function, see <a href="hrf1550170185805.md">Determining if Data Skew Might Impact Performance</a>.</p>
<p class="p">Another use of the RowDistribution function is to get the configuration (number of worker nodes and vworkers) of the <span><b>ML Engine</b></span> cluster.</p></div><div class="section" id="ddn1563998292313__section_N10037_N10021_N10001">
<h2 class="title sectiontitle">RowDistribution Syntax</h2><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM RowDistribution (
    <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> 
) AS alias;
</code></pre></div></div></div></body></html>
