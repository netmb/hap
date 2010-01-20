HAP.UploadFileWindow = function(el, event, callback){
    dialog = new Ext.ux.UploadDialog.Dialog({
        url: '/fileupload/getFile',
        reset_on_hide: false,
        allow_close_on_upload: true,
        upload_autostart: true,
        permitted_extensions: ['jpg', 'jpeg', 'gif', 'png', 'zip', 'JPG', 'JPEG', 'GIF', 'PNG', 'ZIP']
    });
        
    var onUploadSuccess =  function (dialog, filename, data){
        if (data.firmwareid) {
            storeFirmware.reload({
                parms: {
                    firmwareid: data.firmwareid
                }
            });
        }
        if (callback) {
          callback();
        }
    }

    dialog.show();
    dialog.on('uploadsuccess', onUploadSuccess);
}


