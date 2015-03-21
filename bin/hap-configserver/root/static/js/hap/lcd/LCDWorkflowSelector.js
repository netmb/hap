HAP.LCDWorkflowSelector = function(workflow){
    this.workflow = workflow;
    this.currentSelection = null;
}

HAP.LCDWorkflowSelector.prototype.type = 'LCDWorkflowSelector';
HAP.LCDWorkflowSelector.prototype.onSelectionChanged = function(figure){
    if (this.currentSelection != null) {
        this.currentSelection.detachMoveListener(this);
    }
    this.currentSelection = figure;
    if (figure != null && !(figure instanceof HAP.Connection)) {
      Ext.getCmp('lcdPropertyGrid').setGrid(figure);
      this.currentSelection.attachMoveListener(this);
    }
    else {
      Ext.getCmp('lcdPropertyGrid').blank();
    }
}

HAP.LCDWorkflowSelector.prototype.onOtherFigureMoved = function(figure){
}
