HAP.ACWorkflowSelector = function(workflow){
    this.workflow = workflow;
    this.currentSelection = null;
}

HAP.ACWorkflowSelector.prototype.type = 'ACWorkflowSelector';

HAP.ACWorkflowSelector.prototype.onSelectionChanged = function(figure){
		if (this.currentSelection != null) {
        this.currentSelection.detachMoveListener(this);
    }
    this.currentSelection = figure;
    if (figure != null && !(figure instanceof HAP.Connection)) {
      Ext.getCmp('acPropertyGrid').setGrid(figure);
      this.currentSelection.attachMoveListener(this);
    }
    else {
      Ext.getCmp('acPropertyGrid').blank();
    }
}

HAP.ACWorkflowSelector.prototype.onOtherFigureMoved = function(figure){
   
}
