<div class="nested0" aria-labelledby="ariaid-title1" topicindex="1" topicid="gbr1507740693525" id="gbr1507740693525"><h1 class="title topictitle1" id="ariaid-title1">Receiver Operating Characteristic (ROC) (ML Engine)</h1><div class="body conbody">
<p class="p">A receiver operating characteristic (ROC) curve shows the performance of a binary classification model as its discrimination threshold varies. For a range of thresholds, the curve plots the true positive rate against the false positive rate.</p><div class="p">The Receiver Operating Characteristic (ROC) function takes a set of prediction-actual pairs for a binary classification model and calculates the following values for a range of discrimination thresholds:
<ul class="ul" id="gbr1507740693525__ul_ewq_tkh_tx">
<li class="li">True positive rate (TPR)</li>
<li class="li">False positive rate (FPR)</li>
<li class="li">Area under the ROC curve (AUC)</li>
<li class="li">Gini coefficient</li></ul></div><div class="p">A prediction-actual pair for a binary classifier consists of:
<ul class="ul" id="gbr1507740693525__ul_jf3_smh_tx">
<li class="li">Predicted probability that an observation is in the positive class</li>
<li class="li">Actual class of the observation</li></ul></div>
<p class="p">A discrimination threshold determines whether an observation is classified as positive (1) or negative (0). For example, suppose that a model predicts that an observation will be classified as positive with 0.55 probability. If the threshold above which an observation is classified as positive is 0.5, then the observation is classified as positive. If the threshold is 0.6, the observation is classified as negative.</p><div class="p">You can create prediction-actual pairs for ROC with these functions:
<ul class="ul" id="gbr1507740693525__ul_m1q_5ph_xx">
<li class="li"><a href="jku1558470203716.md#dzb1507741498257">AdaBoostPredict (ML Engine)</a></li>
<li class="li"><a href="zif1541519521313.md#ohm1507917337702">DecisionForestPredict_MLE (ML Engine)</a></li>
<li class="li"><a href="hjh1541538691334.md#euz1507663208785">DecisionTreePredict_MLE (ML Engine)</a></li>
<li class="li"><a href="rgh1541529239182.md#xaz1507155725845">GLMPredict_MLE (ML Engine)</a></li>
<li class="li"><a href="jtv1543874390081.md#yuw1507743806357">XGBoostPredict (ML Engine)</a></li></ul></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title2" topicindex="2" topicid="prm1507740880518" xml:lang="en-us" lang="en-us" id="prm1507740880518">
<h2 class="title topictitle2" id="ariaid-title2">ROC Syntax</h2><div class="body refbody"><div class="section" id="prm1507740880518__section_N10011_N1000E_N10001">
<h3 class="title sectiontitle">Version <span>1.8</span></h3><pre class="pre codeblock" xml:space="preserve"><code>SELECT * FROM ROC (
  <span>ON { <var class="keyword varname">table</var> | <var class="keyword varname">view</var> | (<var class="keyword varname">query</var>) }</span> AS InputTable
  { OUT TABLE OutputTable (<var class="keyword varname">output_table</var>) |
    OUT TABLE ROCTable (<var class="keyword varname">ROC_table</var>) }
  USING
  [ ModelIDColumn ('<var class="keyword varname">model_id_column</var>')]
  ProbabilityColumn ('<var class="keyword varname">probability_column</var>')
  ObservationColumn ('<var class="keyword varname">observation_column</var>')
  PositiveClass ('<var class="keyword varname">positive_class_label</var>')
  [ NumThresholds (<var class="keyword varname">num_thresholds</var>)]
  [ ROCValues (<span><b>{'true'|'t'|'yes'|'y'|'1'|'false'|'f'|'no'|'n'|'0'}</b></span>) ]
  [ AUC (<span><b>{'true'|'t'|'yes'|'y'|'1'|'false'|'f'|'no'|'n'|'0'}</b></span>) ]
  [ Gini (<span><b>{'true'|'t'|'yes'|'y'|'1'|'false'|'f'|'no'|'n'|'0'}</b></span>) ]
) AS <var class="keyword varname">alias</var>;</code></pre></div></div></div><div class="topic reference nested1" aria-labelledby="ariaid-title3" topicindex="3" topicid="axf1507740884605" xml:lang="en-us" lang="en-us" id="axf1507740884605">
<h2 class="title topictitle2" id="ariaid-title3">ROC Syntax Elements</h2><div class="body refbody"><div class="section" id="axf1507740884605__section_N10011_N1000E_N10001"><dl class="dl parml"><dt class="dt pt dlterm">OutputTable</dt><dd class="dd pd">[Required if you omit ROCTable, disallowed otherwise.] Specify the name for the output table that the function creates. The <var class="keyword varname">output_table</var> must not already exist.</dd><dt class="dt pt dlterm">ROCTable</dt><dd class="dd pd">[Required if you omit OutputTable, disallowed otherwise.] Specify the name for the ROC table that the function creates. The <var class="keyword varname">ROC_table</var> must not already exist.</dd><dt class="dt pt dlterm">ModelIDColumn</dt><dd class="dd pd">[Optional] Specify the name of the InputTable column that contains the model or partition identifiers for the ROC curves.</dd><dd class="dd pd ddexpand">Use this syntax element only when InputTable contains information for more than one model. The function creates a separate ROC curve for each model identifier in this column. Each model must include exactly two classes in ObservationColumn.</dd><dt class="dt pt dlterm">ProbabilityColumn</dt><dd class="dd pd">Specify the name of the InputTable column that contains the predictions.</dd><dt class="dt pt dlterm">ObservationColumn</dt><dd class="dd pd">Specify the name of the InputTable column that contains the actual classes.</dd><dt class="dt pt dlterm">PositiveClass</dt><dd class="dd pd">Specify the label of the positive class.</dd><dt class="dt pt dlterm">NumThresholds</dt><dd class="dd pd">[Optional] Specify the number of thresholds for the function to use. The <var class="keyword varname">num_thresholds</var> must be a NUMERIC value in the range [1, 10000].</dd><dd class="dd pd ddexpand">Default: 50 (The function uniformly distributes the thresholds between 0 and 1.)</dd><dt class="dt pt dlterm">ROCValues</dt><dd class="dd pd">[Optional with OutputTable, disallowed with ROCTable.] Specify whether the function displays ROC values (thresholds, false positive rates, and true positive rates).</dd><dd class="dd pd ddexpand">Default: 'true'. See the following note.</dd><dt class="dt pt dlterm">AUC</dt><dd class="dd pd">[Optional with OutputTable, disallowed with ROCTable.] Specify whether the function displays the AUC calculated from the ROC values.</dd><dd class="dd pd ddexpand">Default: 'false'. See the following note.</dd><dt class="dt pt dlterm">Gini</dt><dd class="dd pd">[Optional with OutputTable, disallowed with ROCTable.] Specify whether the function displays the Gini coefficient calculated from the ROC values. The Gini coefficient is a measure of inequality among values of a frequency distribution. A Gini coefficient of 0 indicates that all values are the same. The closer the Gini coefficient is to 1, the more unequal are the values in the distribution.</dd><dd class="dd pd ddexpand">Default: 'false'. See the following note.</dd><dd class="dd pd ddexpand">If you specify OutputTable, the valid combinations of ROCValues, AUC, and Gini syntax elements are those that specify one of the following:
<ul class="ul" id="axf1507740884605__ul_kr1_sxr_wx">
<li class="li">ROCValues only</li>
<li class="li">AUC only</li>
<li class="li">Gini only</li>
<li class="li">AUC and Gini</li></ul></dd><dd class="dd pd ddexpand">The function issues an error message if you do any of the following:
<ul class="ul" id="axf1507740884605__ul_owh_dnq_hhb">
<li class="li">Specify AUC only, Gini only, or AUC and Gini only, and ROCValues ('true').
<p class="p">(When specifying AUC only, Gini only, or AUC and Gini only, ROCValues is false by default.)</p></li>
<li class="li">Specify an invalid combination (such as ROCValues ('true') and AUC ('true'), or all three 'false').</li>
<li class="li">Specify ROCTable and also specify any of AUC, Gini, or ROCValues.</li></ul></dd></dl></div></div></div></div>
