<div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="cuu1507837727412" id="cuu1507837727412"><h1 class="title topictitle1" id="ariaid-title1">IPGeo (ML Engine)</h1><div class="body conbody">
<p class="p">IPGeo lets you map IP addresses to location information (country, region,
			city, latitude, longitude, ZIP code, and ISP).</p><div class="p">You can use the locations of web site visitors to improve the effectiveness of online applications. For example:
<ul class="ul" id="cuu1507837727412__ul_ymb_4yk_r1b">
<li class="li">Targeted online advertising</li>
<li class="li">Content localization</li>
<li class="li">Geographic rights management</li>
<li class="li">Enhanced analytics</li>
<li class="li">Online security and fraud prevention</li></ul></div>
<p class="p">For general information about IP databases, see:</p>
<p class="p"><a class="xref" href="http://dev.maxmind.com/geoip/geoip2/geolite2/" target="_blank" title="" shape="rect">http://dev.maxmind.com/geoip/geoip2/geolite2/</a></p>
<p class="p">IPGeo uses files that are preinstalled on <span><b>ML Engine</b></span>. For details, see <a href="tzu1557778477026.md">Preinstalled Files That Functions Use</a>.</p></div><div class="topic reference nested1" aria-labelledby="ariaid-title2" topicindex="2" topicid="fdo1507837763672" xml:lang="en-us" lang="en-us" id="fdo1507837763672">
<h2 class="title topictitle2" id="ariaid-title2">IPGeo Syntax</h2><div class="body refbody"><div class="section" id="fdo1507837763672__section_N1000E_N1000C_N10001">
<h3 class="title sectiontitle">Version 2.4</h3><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM IPGeo (
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span>
  USING
  IPAddressColumn ('<var class="keyword varname">ip_address_column</var>')
  [ Converter ('<var class="keyword varname">file</var>', '<var class="keyword varname">class</var>') ]
  <code class="ph codeph">[ Accumulate ({ '<var class="keyword varname">accumulate_column</var>' | <var class="keyword varname">accumulate_column_range</var> }[,...]) ]</code>
) AS <var class="keyword varname">alias</var>;</code></pre></div></div><div class="related-links"><div class="linklistheader"><p></p><b>Related Information</b></div>
<ul class="linklist linklist relinfo"><div class="linklistmember"><a href="ndv1557782188375.md">Column Specification Syntax Elements</a></div></ul></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title3" topicindex="3" topicid="jlz1507837770702" xml:lang="en-us" lang="en-us" id="jlz1507837770702">
<h2 class="title topictitle2" id="ariaid-title3">IPGeo Syntax Elements</h2><div class="body refbody"><div class="section" id="jlz1507837770702__section_N10011_N1000E_N10001"><dl class="dl parml"><dt class="dt pt dlterm">IPAddressColumn</dt><dd class="dd pd">Specify the name of the input table column that contains the IP addresses.</dd><dt class="dt pt dlterm">Converter</dt><dd class="dd pd">[Optional] Specify the JAR filename and the name of the class that converts the IP address to location information.</dd><dd class="dd pd ddexpand">The JAR file must be installed on <span><b>ML Engine</b></span> and the class name must be the full name, including the package information. The file and class parameters are case-sensitive. The JAR file must contain all the classes that the user-defined converter needs.</dd><dd class="dd pd ddexpand"><span><b>ML Engine</b></span> does not support the creation of new Converter classes. However, it does support existing JAR files—for installation instructions, see <span><cite class="cite">Teradata Vantage™ User Guide</cite>, B700-4002</span>.</dd><dd class="dd pd ddexpand">Default: Converter class that ships with IPGeo function (geolite 1.2.8)</dd><dt class="dt pt dlterm">Accumulate</dt><dd class="dd pd">[Optional] Specify the names of input table columns to copy to the output table.</dd></dl></div></div></div></div>
