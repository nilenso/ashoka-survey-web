<label><%= t("surveys.build.question_title") %> </label>
<input type="text" name="content" value="{{content}}"></input>
<div>
	<label><%= t("activerecord.attributes.question.mandatory") %> </label>
	<input type="checkbox" name="mandatory" value="{{mandatory}}"></input>
</div>
<div>
	<label><%= t("activerecord.attributes.question.max_length") %> </label>
	<input type="number" name="max_length" value="{{max_length}}"></input>
</div>
<div class="upload_files">
    <label><%= t("activerecord.attributes.question.image") %> </label>
    <input name="image" class="fileupload" type="file" name="files[]" accept="image/png, image/jpg">
    <div class="spinner"></div>
 </div>
