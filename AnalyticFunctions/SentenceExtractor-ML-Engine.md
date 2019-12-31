<div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="xrc1507558451771" id="xrc1507558451771"><h1 class="title topictitle1" id="ariaid-title1">SentenceExtractor (ML Engine)</h1><div class="body conbody">
<p class="p">The SentenceExtractor function extracts sentences from English input text. A sentence ends with a punctuation mark such as period (.), question mark (?), or exclamation mark (!).</p>
<p class="p">Many Natural Language Processing (NLP) processing tasks (such as
			Part-Of-Speech tagging and chunking) begin by identifying sentences.</p>
<p class="p">SentenceExtractor uses files that are preinstalled on <span><b>ML Engine</b></span>. For details, see <a href="tzu1557778477026.md">Preinstalled Files That Functions Use</a>.</p></div><div class="topic reference nested1" aria-labelledby="ariaid-title2" topicindex="2" topicid="hii1507558544576" xml:lang="en-us" lang="en-us" id="hii1507558544576">
<h2 class="title topictitle2" id="ariaid-title2">SentenceExtractor Syntax</h2><div class="body refbody"><div class="section" id="hii1507558544576__section_N1000E_N1000C_N10001">
<h3 class="title sectiontitle">Version 1.4</h3><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM SentenceExtractor (
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span>
  USING
  TextColumn ('<var class="keyword varname">text_column</var>')
  <code class="ph codeph">[ Accumulate ({ '<var class="keyword varname">accumulate_column</var>' | <var class="keyword varname">accumulate_column_range</var> }[,...]) ]</code>
) AS <var class="keyword varname">alias</var>;</code></pre></div></div><div class="related-links"><div class="linklistheader"><p></p><b>Related Information</b></div>
<ul class="linklist linklist relinfo"><div class="linklistmember"><a href="ndv1557782188375.md">Column Specification Syntax Elements</a></div></ul></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title3" topicindex="3" topicid="chk1507558610656" xml:lang="en-us" lang="en-us" id="chk1507558610656">
<h2 class="title topictitle2" id="ariaid-title3">SentenceExtractor Syntax Elements</h2><div class="body refbody"><div class="section" id="chk1507558610656__section_N10011_N1000E_N10001"><dl class="dl parml"><dt class="dt pt dlterm">TextColumn</dt><dd class="dd pd">Specify the name of the input column that contains the text from which to extract sentences.</dd><dt class="dt pt dlterm">Accumulate</dt><dd class="dd pd">[Optional] Specify the names of the input columns to copy to the output table.</dd></dl></div></div></div></div>
