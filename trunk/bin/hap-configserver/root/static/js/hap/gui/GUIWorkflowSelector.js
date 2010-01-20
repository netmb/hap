HAP.GUIWorkflowSelector = function(workflow){
    this.workflow = workflow;
    this.currentSelection = null;
}

HAP.GUIWorkflowSelector.prototype.type = 'GUIWorkflowSelector';

HAP.GUIWorkflowSelector.prototype.onSelectionChanged = function(figure){
    if (this.currentSelection != null) {
        this.currentSelection.detachMoveListener(this);
    }
    this.currentSelection = figure;
    if (figure != null) {
      Ext.getCmp('guiPropertyGrid').setGrid(figure);
      this.currentSelection.attachMoveListener(this);
    }
    else {
      Ext.getCmp('guiPropertyGrid').blank();
    }
}

HAP.GUIWorkflowSelector.prototype.onOtherFigureMoved = function(figure){
}
