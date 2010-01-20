HAP.GridUserRoles = function(userId){
    var checkColumn = new Ext.grid.CheckColumn({
        header: 'active',
        dataIndex: 'status',
        width: 35
    });
    var cm = new Ext.grid.ColumnModel([{
        id: 'role',
        header: 'Role',
        dataIndex: 'role',
        sortable: true,
        width: 295
    }, checkColumn]);
    storeUserRoles.load({
        params: {
            id: userId
        }
    });
    this.clicksToEdit = 1;
    this.id = 'gridUserRoles';
    this.ds = storeUserRoles;
    this.cm = cm;
    this.frame = false;
    this.plugins = [checkColumn];
    this.height = 190;
    this.width = 350;
    this.layout = 'fit';
    HAP.GridUserRoles.superclass.constructor.call(this);
}

Ext.extend(HAP.GridUserRoles, Ext.grid.EditorGridPanel, {});

