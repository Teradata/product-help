<html><head></head><body><div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="usr1507669357350" id="usr1507669357350"><h1 class="title topictitle1" id="ariaid-title1">Linear Regression (ML Engine)</h1><div class="body conbody">
<p class="p">The Linear Regression function is composed of the functions LinReg and LinRegInternal. LinRegInternal takes a data set and outputs a linear regression model. LinReg takes the linear regression model and outputs its coefficients. The 0th coefficient corresponds to the slope intercept.</p>
<p class="p">The output of the Linear Regression function can be input to the <a href="lds1558531774578.md#vol1507670147308">LinRegPredict (ML Engine)</a> function (as the model table).</p></div><div class="topic reference nested1" aria-labelledby="ariaid-title2" topicindex="2" topicid="lzg1507669513896" xml:lang="en-us" lang="en-us" id="lzg1507669513896">
<h2 class="title topictitle2" id="ariaid-title2">Linear Regression Syntax</h2><div class="body refbody"><div class="section" id="lzg1507669513896__section_N1000E_N1000C_N10001">
<h3 class="title sectiontitle">LinReg version 1.5, LinRegInternal version 2.4</h3><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM LinReg (
  ON LinRegInternal (
    <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span>
  ) AS <var class="keyword varname">alias_1</var> PARTITION BY 1
) AS <var class="keyword varname">alias_2</var>;</code></pre>
<p class="p">PARTITION BY 1 is required because all input data must be submitted to one worker.</p></div></div></div></div></body></html>
