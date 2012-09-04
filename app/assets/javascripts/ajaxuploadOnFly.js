(function($) {
    $.fn.uploadOnFly = function(options) {
        var settings = $.extend({
            'allowedExt': "jpg|png|jpeg|gif|doc|docx|ppt|pptx|xls|xlsx|tex|pdf",
            'actionUrl': "/newclientform/upload-files",
            'fieldName': "uploadfile",
            'errorExt': "The supplied file format is not allowed",
            'errorUpload': "Unable to upload file, try again",
            'loadingText': "Loading..."
        }, options);

        var main_container = $(this);
        var btnUpload = main_container.find('.upload-container');
        var status = main_container.find('.status-msg');
        var ul = main_container.find('.file-list');
        var deleteButton = main_container.find('.delete-file');
        var fileExtension="";
        new AjaxUpload(btnUpload, {
            action: settings.actionUrl,
            name: settings.fieldName,
            onSubmit: function(file, ext) {
                fileExtension=ext;
                if (!(ext && (String(ext).match(new RegExp(settings.allowedExt, 'g'))))) {
                    // extension is not allowed 
                    
                    status.text(settings.errorExt).show();
                    return false;
                }
                status.text(settings.loadingText).show();
            },
            onComplete: function(file, response) {
                
                //On completion clear the status
                status.text('');
                //Add uploaded file to list
                var btnDelete = "<span class='delete-file'></span>";
                var icon_span='<span class="sprite-files sprite-'+fileExtension+'"></span>';
                if (response != "error") {
                    $('<li id="'+response+'"></li>')
                    .appendTo(ul)
                    .html(icon_span + file + btnDelete)
                    .addClass('success file-list-name');
                    status.hide();
                } else {
                    status.text(settings.errorUpload).show();
                    // $('<li></li>').appendTo('#files').html(file +btnDelete).addClass('error file-list-name');
                }
            }
        });
        deleteButton.live('click', function() {
            $(this).parent().fadeOut('slow', function() {
                $(this).remove();
            });
        });
    };
})(jQuery);
