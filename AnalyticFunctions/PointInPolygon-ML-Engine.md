<div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="ymo1507842459658" id="ymo1507842459658"><h1 class="title topictitle1" id="ariaid-title1">PointInPolygon (ML Engine)</h1><div class="body conbody">
<p class="p">The PointInPolygon function takes a list of location points and a list of
			polygons and returns a list of binary values for every point and polygon combination,
			which indicates whether the point is contained in the polygon.</p><div class="fig fignone" id="ymo1507842459658__fig_ogl_sbr_pw"><div class="caption"></div><br clear="none"></br><img class="image" id="ymo1507842459658__image_xws_sbr_pw" src="vsj1466005943592.svg" alt="How Machine Learning Engine function PointInPolygon works"></img><br clear="none"></br></div>
<p class="p">The PointInPolygon function works only on 2D spatial objects.</p>
<p class="p">The function determines whether a given point in the plane lies inside or outside of a polygon. It has various applications in many fields such as computer graphics, geographical information systems (GIS), and CAD.</p>
<p class="p">In the following example, point A is in the polygon and point B is outside of the polygon.</p><div class="fig fignone" id="ymo1507842459658__fig_pyr_xbr_pw"><div class="caption"></div><br clear="none"></br><img class="image" id="ymo1507842459658__image_tlp_ybr_pw" src="jrc1466005944656.svg" alt="Points inside and outside a polygon (Machine Learning Engine function PointInPolygon)"></img><br clear="none"></br></div>
<p class="p">A use case for this function is to determine in which drive-time polygon surrounding a store a customer resides. This information helps in mailer targeting.</p>
<p class="p">Another use case is to determine which cell phones are frequently within a polygon surrounding an airport. This information helps in identifying frequent fliers.</p></div><div class="topic concept nested1" aria-labelledby="ariaid-title2" topicindex="2" topicid="tzl1466004896356" xml:lang="en-us" lang="en-us" id="tzl1466004896356">
<h2 class="title topictitle2" id="ariaid-title2">PointInPolygon Syntax</h2><div class="topic reference nested2" aria-labelledby="ariaid-title3" topicindex="3" topicid="qcm1507842511202" xml:lang="en-us" lang="en-us" id="qcm1507842511202">
<h3 class="title topictitle3" id="ariaid-title3">Small Polygon Count and Large Point Count</h3><div class="body refbody"><div class="section" id="qcm1507842511202__section_N1000E_N1000C_N10001">
<h4 class="title sectiontitle">Version <span>1.4</span></h4><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM PointInPolygon (
  ON <var class="keyword varname">source_table</var> AS SourceTable PARTITION BY ANY
  ON <var class="keyword varname">reference_table</var> AS ReferenceTable DIMENSION
  USING
  SourceLocationColumn ('<var class="keyword varname">source_location_point_column</var>' [, '<var class="keyword varname">source_location_point_column_2</var>' ])
  ReferenceLocationColumn ('<var class="keyword varname">reference_location_polygon_column</var>')
  ReferenceNameColumns ({ '<var class="keyword varname">reference_name_column</var>' | <var class="keyword varname">reference_name_column_range</var> }[,...])
  [ OutputAll (<span><b>{'true'|'t'|'yes'|'y'|'1'|'false'|'f'|'no'|'n'|'0'}</b></span>) ]
  <code class="ph codeph">[ Accumulate ({ '<var class="keyword varname">accumulate_column</var>' | <var class="keyword varname">accumulate_column_range</var> }[,...]) ]</code>
) AS <var class="keyword varname">alias</var>;</code></pre></div></div><div class="related-links"><div class="linklistheader"><p></p><b>Related Information</b></div>
<ul class="linklist linklist relinfo"><div class="linklistmember"><a href="ndv1557782188375.md">Column Specification Syntax Elements</a></div></ul></div></div><div class="topic reference nested2" aria-labelledby="ariaid-title4" topicindex="4" topicid="ehf1507842516163" xml:lang="en-us" lang="en-us" id="ehf1507842516163">
<h3 class="title topictitle3" id="ariaid-title4">Large Polygon Count and Small Point Count</h3><div class="body refbody"><div class="section" id="ehf1507842516163__section_N1000E_N1000C_N10001">
<h4 class="title sectiontitle">Version <span>1.4</span></h4><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM PointInPolygon (
  ON <var class="keyword varname">dimension_table</var> AS SourceTable DIMENSION
  ON <var class="keyword varname">reference_table</var> AS ReferenceTable PARTITION BY ANY
  USING
  SourceLocationColumn ('<var class="keyword varname">source_location_point_column</var>' [, '<var class="keyword varname">source_location_point_column_2</var>' ])
  ReferenceLocationColumn ('<var class="keyword varname">reference_location_polygon_column</var>')
  ReferenceNameColumns ({ '<var class="keyword varname">reference_name_column</var>' | <var class="keyword varname">reference_name_column_range</var> }[,...])
  OutputAll (<span><b>{'true'|'t'|'yes'|'y'|'1'|'false'|'f'|'no'|'n'|'0'}</b></span>)
  <code class="ph codeph">[ Accumulate ({ '<var class="keyword varname">accumulate_column</var>' | <var class="keyword varname">accumulate_column_range</var> }[,...]) ]</code>
) AS <var class="keyword varname">alias</var>;</code></pre></div></div><div class="related-links"><div class="linklistheader"><p></p><b>Related Information</b></div>
<ul class="linklist linklist relinfo"><div class="linklistmember"><a href="ndv1557782188375.md">Column Specification Syntax Elements</a></div></ul></div></div><div class="topic reference nested2" aria-labelledby="ariaid-title5" topicindex="5" topicid="xrq1507842520598" xml:lang="en-us" lang="en-us" id="xrq1507842520598">
<h3 class="title topictitle3" id="ariaid-title5">Only to Determine Relations of Points and Polygons in Same Group</h3><div class="body refbody"><div class="section" id="xrq1507842520598__section_N1000E_N1000C_N10001">
<h4 class="title sectiontitle">Version <span>1.4</span></h4><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM PointInPolygon (
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> AS SourceTable PARTITION BY <var class="keyword varname">group_key</var> 
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> AS ReferenceTable PARTITION BY <var class="keyword varname">group_key</var>
  USING
  SourceLocationColumn ('<var class="keyword varname">source_location_point_column</var>' [, '<var class="keyword varname">source_location_point_column_2</var>' ])
  ReferenceLocationColumn ('<var class="keyword varname">reference_location_polygon_column</var>')
  ReferenceNameColumns ({ '<var class="keyword varname">reference_name_column</var>' | <var class="keyword varname">reference_name_column_range</var> }[,...])
  OutputAll (<span><b>{'true'|'t'|'yes'|'y'|'1'|'false'|'f'|'no'|'n'|'0'}</b></span>)
  <code class="ph codeph">[ Accumulate ({ '<var class="keyword varname">accumulate_column</var>' | <var class="keyword varname">accumulate_column_range</var> }[,...]) ]</code>
) AS <var class="keyword varname">alias</var>;</code></pre></div></div><div class="related-links"><div class="linklistheader"><p></p><b>Related Information</b></div>
<ul class="linklist linklist relinfo"><div class="linklistmember"><a href="ndv1557782188375.md">Column Specification Syntax Elements</a></div></ul></div></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title6" topicindex="6" topicid="aya1507842524383" xml:lang="en-us" lang="en-us" id="aya1507842524383">
<h2 class="title topictitle2" id="ariaid-title6">PointInPolygon Syntax Elements</h2><div class="body refbody"><div class="section" id="aya1507842524383__section_N10011_N1000E_N10001"><dl class="dl parml"><dt class="dt pt dlterm">SourceLocationColumn</dt><dd class="dd pd">Specify the names of the SourceTable columns that contain the point coordinate values.
<p class="p">If you specify only one column, specify the point coordinates in well-known text (WKT) syntax. For example, the string 'POINT (30 10)' is the WKT markup syntax that describes a point with x coordinate 30 and y coordinate 10.</p>
<p class="p">If you specify two columns, they represent the two coordinates of the input points (for example, latitude and longitude).</p><div class="note tip" id="aya1507842524383__note_N10065_N1004D_N10040_N1003D_N10015_N10011_N1000E_N10001"><span><b>Tip</b></span><div class="notebody">When you specify two columns, the output of the IPGeo function can be input to this function.</div></div></dd><dt class="dt pt dlterm">ReferenceLocationColumn</dt><dd class="dd pd">Specify the name of the ReferenceTable column that contains the polygon coordinate values. The column content must be of type WKT.</dd><dt class="dt pt dlterm">ReferenceNameColumns</dt><dd class="dd pd">Specify the names of the ReferenceTable columns that contain the polygon names. The function copies these columns to the output table.</dd><dt class="dt pt dlterm">OutputAll</dt><dd class="dd pd">[Optional] Specify whether to indicate in the output table when the point is not in a polygon.</dd><dd class="dd pd ddexpand">Default: 'false'</dd><dt class="dt pt dlterm">Accumulate</dt><dd class="dd pd">[Optional] Specify the SourceTable columns to copy to the output table.</dd></dl></div></div></div></div>
