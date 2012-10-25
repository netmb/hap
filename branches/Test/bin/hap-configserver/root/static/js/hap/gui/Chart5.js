HAP.Chart5 = function(config, viewPortCall){
    this.conf = {};
    this.conf.id = 0;
    this.conf.tmpId = 'x' + Math.random() + 'x';
    this.conf.type = 'HAP.Chart5';
    this.conf.imagePath = '/static/images/gui/';
    this.conf.display = {
        x: 0,
        y: 0,
        height: 150,
        width: 150,
        'z-Index': 2,
        'Update Interval (s)': 3600,
        'Start-Offset (m)': 60,
        'Interval (m)': 60,
        'Chart-Properties': '',
        'Chart-Type': 'Line',
        'Chart-X-Interval': 1,
        'sourceTemplate': {
            'HAP-Module': '',
            'HAP-Device': '',
            'Description': '',
            'chart.colors': '',
            'chart.fillstyle': '',
            'chart.key': ''
        },
        'dataSources': [],
        'chart': {
            'Line': {
              'chart.background.barcolor1':   'rgba(0,0,0,0)',
              'chart.background.barcolor2':   'rgba(0,0,0,0)',
              'chart.background.grid':        1,
              'chart.background.grid.width':  1,
              'chart.background.grid.hsize':  25,
              'chart.background.grid.vsize':  25,
              'chart.background.grid.color':  '#ddd',
              'chart.background.grid.vlines': true,
              'chart.background.grid.hlines': true,
              'chart.background.grid.border': true,
              'chart.background.grid.autofit':           true,
              'chart.background.grid.autofit.align':     false,
              'chart.background.grid.autofit.numhlines': 5,
              'chart.background.grid.autofit.numvlines': 20,
              'chart.background.hbars':       null,
              'chart.background.image':       null,
              'chart.labels':                 null,
              'chart.labels.ingraph':         null,
              'chart.labels.above':           false,
              'chart.labels.above.size':      8,
              'chart.xtickgap':               20,
              'chart.smallxticks':            3,
              'chart.largexticks':            5,
              'chart.ytickgap':               20,
              'chart.smallyticks':            3,
              'chart.largeyticks':            5,
              'chart.numyticks':              10,
              'chart.linewidth':              1.01,
              'chart.colors':                 ['red', '#0f0', '#00f', '#f0f', '#ff0', '#0ff'],
              'chart.hmargin':                0,
              'chart.tickmarks.dot.color':    'white',
              'chart.tickmarks':              null,
              'chart.tickmarks.linewidth':    null,
              'chart.ticksize':               3,
              'chart.gutter.left':            25,
              'chart.gutter.right':           25,
              'chart.gutter.top':             25,
              'chart.gutter.bottom':          25,
              'chart.tickdirection':          -1,
              'chart.yaxispoints':            5,
              'chart.fillstyle':              '',  //HAP
              'chart.xaxispos':               'bottom',
              'chart.yaxispos':               'left',
              'chart.xticks':                 null,
              'chart.text.size':              10,
              'chart.text.angle':             0,
              'chart.text.color':             'black',
              'chart.text.font':              'Verdana',
              'chart.ymin':                   0,  //HAP
              'chart.ymax':                   100, //HAP
              'chart.title':                  '',
              'chart.title.background':       null,
              'chart.title.hpos':             null,
              'chart.title.vpos':             0.5,
              'chart.title.bold':             true,
              'chart.title.font':             null,
              'chart.title.xaxis':            '',
              'chart.title.xaxis.bold':       true,
              'chart.title.xaxis.size':       null,
              'chart.title.xaxis.font':       null,
              'chart.title.yaxis':            '',
              'chart.title.yaxis.bold':       true,
              'chart.title.yaxis.size':       null,
              'chart.title.yaxis.font':       null,
              'chart.title.xaxis.pos':        null,
              'chart.title.yaxis.pos':        null,
              'chart.shadow':                 false,
              'chart.shadow.offsetx':         2,
              'chart.shadow.offsety':         2,
              'chart.shadow.blur':            3,
              'chart.shadow.color':           'rgba(0,0,0,0.5)',
              'chart.tooltips':               [], //HAP
              'chart.tooltips.hotspot.xonly': false,
              'chart.tooltips.effect':        'fade',
              'chart.tooltips.css.class':     'RGraph_tooltip',
              'chart.tooltips.highlight':     true,
              'chart.highlight.stroke':       '#999',
              'chart.highlight.fill':         'white',
              'chart.stepped':                false,
              'chart.key':                    [],
              'chart.key.background':         'white',
              'chart.key.position':           'graph',
              'chart.key.halign':             null,
              'chart.key.shadow':             false,
              'chart.key.shadow.color':       '#666',
              'chart.key.shadow.blur':        3,
              'chart.key.shadow.offsetx':     2,
              'chart.key.shadow.offsety':     2,
              'chart.key.position.gutter.boxed': true,
              'chart.key.position.x':         null,
              'chart.key.position.y':         null,
              'chart.key.color.shape':        'square',
              'chart.key.rounded':            true,
              'chart.key.linewidth':          1,
              'chart.key.interactive':        false,
              'chart.contextmenu':            null,
              'chart.ylabels':                true,
              'chart.ylabels.count':          5,
              'chart.ylabels.inside':         false,
              'chart.ylabels.invert':         false,
              'chart.xlabels.inside':         false,
              'chart.xlabels.inside.color':   'rgba(255,255,255,0.5)',
              'chart.noaxes':                 false,
              'chart.noyaxis':                false,
              'chart.noxaxis':                false,
              'chart.noendxtick':             false,
              'chart.units.post':             '',
              'chart.units.pre':              '',
              'chart.scale.decimals':         null,
              'chart.scale.point':            '.',
              'chart.scale.thousand':         ',',
              'chart.crosshairs':             false,
              'chart.crosshairs.color':       '#333',
              'chart.crosshairs.hline':       true,
              'chart.crosshairs.vline':       true,
              'chart.annotatable':            false,
              'chart.annotate.color':         'black',
              'chart.axesontop':              false,
              'chart.filled':                 false,
              'chart.filled.range':           false,
              'chart.filled.accumulative':    true,
              'chart.variant':                null,
              'chart.axis.color':             'black',
              'chart.zoom.factor':            1.5,
              'chart.zoom.fade.in':           true,
              'chart.zoom.fade.out':          true,
              'chart.zoom.hdir':              'right',
              'chart.zoom.vdir':              'down',
              'chart.zoom.frames':            25,
              'chart.zoom.delay':             16.666,
              'chart.zoom.shadow':            true,
              'chart.zoom.mode':              'canvas',
              'chart.zoom.thumbnail.width':   75,
              'chart.zoom.thumbnail.height':  75,
              'chart.zoom.background':        true,
              'chart.zoom.action':            'zoom',
              'chart.backdrop':               false,
              'chart.backdrop.size':          30,
              'chart.backdrop.alpha':         0.2,
              'chart.resizable':              false,
              'chart.resize.handle.adjust':   [0,0],
              'chart.resize.handle.background': null,
              'chart.adjustable':             false,
              'chart.noredraw':               false,
              'chart.outofbounds':            false,
              'chart.chromefix':              true,
              'chart.animation.factor':       1,
              'chart.animation.unfold.x':     false,
              'chart.animation.unfold.y':     true,
              'chart.animation.unfold.initial': 2,
              'chart.curvy':                    false,
              'chart.curvy.factor':             0.25,
              'chart.line.visible':             true
            },
            'Bar': {
              'chart.background.barcolor1':   'rgba(0,0,0,0)',
              'chart.background.barcolor2':   'rgba(0,0,0,0)',
              'chart.background.grid':        true,
              'chart.background.grid.color':  '#ddd',
              'chart.background.grid.width':  1,
              'chart.background.grid.hsize':  20,
              'chart.background.grid.vsize':  20,
              'chart.background.grid.vlines': true,
              'chart.background.grid.hlines': true,
              'chart.background.grid.border': true,
              'chart.background.grid.autofit':true,
              'chart.background.grid.autofit.numhlines': 5,
              'chart.background.grid.autofit.numvlines': 20,
              'chart.background.image':       null,
              'chart.ytickgap':               20,
              'chart.smallyticks':            3,
              'chart.largeyticks':            5,
              'chart.numyticks':              10,
              'chart.hmargin':                5,
              'chart.strokecolor':            '#666',
              'chart.axis.color':             'black',
              'chart.gutter.top':             25,
              'chart.gutter.bottom':          25,
              'chart.gutter.left':            25,
              'chart.gutter.right':           25,
              'chart.labels':                 null,
              'chart.labels.ingraph':         null,
              'chart.labels.above':           false,
              'chart.labels.above.decimals':  0,
              'chart.labels.above.size':      null,
              'chart.labels.above.angle':     null,
              'chart.ylabels':                true,
              'chart.ylabels.count':          5,
              'chart.ylabels.inside':         false,
              'chart.xlabels.offset':         0,
              'chart.xaxispos':               'bottom',
              'chart.yaxispos':               'left',
              'chart.text.color':             'black',
              'chart.text.size':              10,
              'chart.text.angle':             0,
              'chart.text.font':              'Verdana',
              'chart.ymin':                   0,
              'chart.ymax':                   null,
              'chart.title':                  '',
              'chart.title.font':             null,
              'chart.title.background':       null,
              'chart.title.hpos':             null,
              'chart.title.vpos':             null,
              'chart.title.bold':             true,
              'chart.title.xaxis':            '',
              'chart.title.xaxis.bold':       true,
              'chart.title.xaxis.size':       null,
              'chart.title.xaxis.font':       null,
              'chart.title.yaxis':            '',
              'chart.title.yaxis.bold':       true,
              'chart.title.yaxis.size':       null,
              'chart.title.yaxis.font':       null,
              'chart.title.xaxis.pos':        null,
              'chart.title.yaxis.pos':        null,
              'chart.colors':                 ['rgb(0,0,255)', '#0f0', '#00f', '#ff0', '#0ff', '#0f0'],
              'chart.colors.sequential':      false,
              'chart.colors.reverse':         false,
              'chart.grouping':               'grouped',
              'chart.variant':                'bar',
              'chart.shadow':                 false,
              'chart.shadow.color':           '#666',
              'chart.shadow.offsetx':         3,
              'chart.shadow.offsety':         3,
              'chart.shadow.blur':            3,
              'chart.tooltips':               null,
              'chart.tooltips.effect':        'fade',
              'chart.tooltips.css.class':     'RGraph_tooltip',
              'chart.tooltips.event':         'onclick',
              'chart.tooltips.highlight':     true,
              'chart.highlight.stroke':       'black',
              'chart.highlight.fill':         'rgba(255,255,255,0.5)',
              'chart.background.hbars':       null,
              'chart.key':                    [],
              'chart.key.background':         'white',
              'chart.key.position':           'graph',
              'chart.key.shadow':             false,
              'chart.key.shadow.color':       '#666',
              'chart.key.shadow.blur':        3,
              'chart.key.shadow.offsetx':     2,
              'chart.key.shadow.offsety':     2,
              'chart.key.position.gutter.boxed': true,
              'chart.key.position.x':         null,
              'chart.key.position.y':         null,
              'chart.key.halign':             'right',
              'chart.key.color.shape':        'square',
              'chart.key.rounded':            true,
              'chart.key.text.size':          10,
              'chart.key.linewidth':          1,
              'chart.contextmenu':            null,
              'chart.line':                   null,
              'chart.units.pre':              '',
              'chart.units.post':             '',
              'chart.scale.decimals':         0,
              'chart.scale.point':            '.',
              'chart.scale.thousand':         ',',
              'chart.crosshairs':             false,
              'chart.crosshairs.color':       '#333',
              'chart.crosshairs.hline':       true,
              'chart.crosshairs.vline':       true,
              'chart.linewidth':              1,
              'chart.annotatable':            false,
              'chart.annotate.color':         'black',
              'chart.zoom.factor':            1.5,
              'chart.zoom.fade.in':           true,
              'chart.zoom.fade.out':          true,
              'chart.zoom.hdir':              'right',
              'chart.zoom.vdir':              'down',
              'chart.zoom.frames':            25,
              'chart.zoom.delay':             16.666,
              'chart.zoom.shadow':            true,
              'chart.zoom.mode':              'canvas',
              'chart.zoom.thumbnail.width':   75,
              'chart.zoom.thumbnail.height':  75,
              'chart.zoom.background':        true,
              'chart.resizable':              false,
              'chart.resize.handle.adjust':   [0,0],
              'chart.resize.handle.background': null,
              'chart.adjustable':             false,
              'chart.noaxes':                 false,
              'chart.noxaxis':                false,
              'chart.noyaxis':                false
            },
            'HBar': {
              'chart.gutter.left':            75,
              'chart.gutter.right':           25,
              'chart.gutter.top':             35,
              'chart.gutter.bottom':          25,
              'chart.background.grid':        true,
              'chart.background.grid.color':  '#ddd',
              'chart.background.grid.width':  1,
              'chart.background.grid.hsize':  25,
              'chart.background.grid.vsize':  25,
              'chart.background.barcolor1':   'white',
              'chart.background.barcolor2':   'white',
              'chart.background.grid.hlines': true,
              'chart.background.grid.vlines': true,
              'chart.background.grid.border': true,
              'chart.background.grid.autofit':true,
              'chart.background.grid.autofit.numhlines': 14,
              'chart.background.grid.autofit.numvlines': 20,
              'chart.title':                  '',
              'chart.title.background':       null,
              'chart.title.xaxis':            '',
              'chart.title.xaxis.bold':       true,
              'chart.title.xaxis.size':       null,
              'chart.title.xaxis.font':       null,
              'chart.title.yaxis':            '',
              'chart.title.yaxis.bold':       true,
              'chart.title.yaxis.size':       null,
              'chart.title.yaxis.font':       null,
              'chart.title.xaxis.pos':        null,
              'chart.title.yaxis.pos':        10,
              'chart.title.hpos':             null,
              'chart.title.vpos':             null,
              'chart.title.bold':             true,
              'chart.title.font':             null,
              'chart.text.size':              10,
              'chart.text.color':             'black',
              'chart.text.font':              'Verdana',
              'chart.colors':                 ['red', 'blue', 'green', 'pink', 'yellow', 'cyan', 'navy', 'gray', 'black'],
              'chart.labels':                 [],
              'chart.labels.above':           false,
              'chart.labels.above.decimals':  0,
              'chart.xlabels':                true,
              'chart.contextmenu':            null,
              'chart.key':                    [],
              'chart.key.background':         'white',
              'chart.key.position':           'graph',
              'chart.key.halign':             'right',
              'chart.key.shadow':             false,
              'chart.key.shadow.color':       '#666',
              'chart.key.shadow.blur':        3,
              'chart.key.shadow.offsetx':     2,
              'chart.key.shadow.offsety':     2,
              'chart.key.position.gutter.boxed': true,
              'chart.key.position.x':         null,
              'chart.key.position.y':         null,
              'chart.key.color.shape':        'square',
              'chart.key.rounded':            true,
              'chart.key.linewidth':          1,
              'chart.units.pre':              '',
              'chart.units.post':             '',
              'chart.units.ingraph':          false,
              'chart.strokestyle':            'black',
              'chart.xmin':                   0,
              'chart.xmax':                   0,
              'chart.axis.color':             'black',
              'chart.shadow':                 false,
              'chart.shadow.color':           '#666',
              'chart.shadow.blur':            3,
              'chart.shadow.offsetx':         3,
              'chart.shadow.offsety':         3,
              'chart.vmargin':                3,
              'chart.grouping':               'grouped',
              'chart.tooltips':               null,
              'chart.tooltips.event':         'onclick',
              'chart.tooltips.effect':        'fade',
              'chart.tooltips.css.class':     'RGraph_tooltip',
              'chart.tooltips.highlight':     true,
              'chart.highlight.fill':         'rgba(255,255,255,0.5)',
              'chart.highlight.stroke':       'black',
              'chart.annotatable':            false,
              'chart.annotate.color':         'black',
              'chart.zoom.factor':            1.5,
              'chart.zoom.fade.in':           true,
              'chart.zoom.fade.out':          true,
              'chart.zoom.hdir':              'right',
              'chart.zoom.vdir':              'down',
              'chart.zoom.frames':            25,
              'chart.zoom.delay':             16.666,
              'chart.zoom.shadow':            true,
              'chart.zoom.mode':              'canvas',
              'chart.zoom.thumbnail.width':   75,
              'chart.zoom.thumbnail.height':  75,
              'chart.zoom.background':        true,
              'chart.zoom.action':            'zoom',
              'chart.resizable':              false,
              'chart.resize.handle.adjust':   [0,0],
              'chart.resize.handle.background': null,
              'chart.scale.point':            '.',
              'chart.scale.thousand':         ',',
              'chart.scale.decimals':         null,
              'chart.noredraw':               false
            },
            'HProgress': {
              'chart.min':                0,
              'chart.colors':             ['#0c0'],
              'chart.strokestyle':        '#999',
              'chart.tickmarks':          true,
              'chart.tickmarks.color':    'black',
              'chart.tickmarks.inner':    false,
              'chart.gutter.left':        25,
              'chart.gutter.right':       25,
              'chart.gutter.top':         25,
              'chart.gutter.bottom':      25,
              'chart.numticks':           10,
              'chart.numticks.inner':     50,
              'chart.background.color':   '#eee',
              'chart.shadow':             false,
              'chart.shadow.color':       'rgba(0,0,0,0.5)',
              'chart.shadow.blur':        3,
              'chart.shadow.offsetx':     3,
              'chart.shadow.offsety':     3,
              'chart.title':              '',
              'chart.title.background':   null,
              'chart.title.hpos':         null,
              'chart.title.vpos':         null,
              'chart.title.bold':         true,
              'chart.title.font':         null,
              'chart.text.size':          10,
              'chart.text.color':         'black',
              'chart.text.font':          'Verdana',
              'chart.contextmenu':        null,
              'chart.units.pre':          '',
              'chart.units.post':         '',
              'chart.tooltips':           [],
              'chart.tooltips.effect':    'fade',
              'chart.tooltips.css.class': 'RGraph_tooltip',
              'chart.tooltips.highlight': true,
              'chart.highlight.stroke':   'black',
              'chart.highlight.fill':     'rgba(255,255,255,0.5)',
              'chart.annotatable':        false,
              'chart.annotate.color':     'black',
              'chart.zoom.mode':          'canvas',
              'chart.zoom.factor':        1.5,
              'chart.zoom.fade.in':       true,
              'chart.zoom.fade.out':      true,
              'chart.zoom.hdir':          'right',
              'chart.zoom.vdir':          'down',
              'chart.zoom.frames':            25,
              'chart.zoom.delay':             16.666,
              'chart.zoom.shadow':        true,
              'chart.zoom.background':    true,
              'chart.zoom.thumbnail.width': 100,
              'chart.zoom.thumbnail.height': 100,
              'chart.arrows':             false,
              'chart.margin':             0,
              'chart.resizable':              false,
              'chart.resize.handle.adjust':   [0,0],
              'chart.resize.handle.background': null,
              'chart.label.inner':        false,
              'chart.adjustable':         false,
              'chart.scale.decimals':     0,
              'chart.key':                [],
              'chart.key.background':     'white',
              'chart.key.position':       'gutter',
              'chart.key.halign':             'right',
              'chart.key.shadow':         false,
              'chart.key.shadow.color':   '#666',
              'chart.key.shadow.blur':    3,
              'chart.key.shadow.offsetx': 2,
              'chart.key.shadow.offsety': 2,
              'chart.key.position.gutter.boxed': false,
              'chart.key.position.x':     null,
              'chart.key.position.y':     null,
              'chart.key.color.shape':    'square',
              'chart.key.rounded':        true,
              'chart.key.linewidth':      1,
              'chart.key.color.shape':    'square',
              'chart.labels.position':     'bottom'
            },
            'VProgress': {
              'chart.colors':             ['#0c0'],
              'chart.strokestyle':        '#999',
              'chart.tickmarks':          true,
              'chart.tickmarks.zerostart':false,
              'chart.tickmarks.color':    'black',
              'chart.tickmarks.inner':    false,
              'chart.gutter.left':        25,
              'chart.gutter.right':       25,
              'chart.gutter.top':         25,
              'chart.gutter.bottom':      25,
              'chart.numticks':           10,
              'chart.numticks.inner':     50,
              'chart.background.color':   '#eee',
              'chart.shadow':             false,
              'chart.shadow.color':       'rgba(0,0,0,0.5)',
              'chart.shadow.blur':        3,
              'chart.shadow.offsetx':     3,
              'chart.shadow.offsety':     3,
              'chart.title':              '',
              'chart.title.background':   null,
              'chart.title.hpos':         null,
              'chart.title.vpos':         null,
              'chart.title.bold':         true,
              'chart.title.font':             null,
              'chart.width':              0,
              'chart.height':             0,
              'chart.text.size':          10,
              'chart.text.color':         'black',
              'chart.text.font':          'Verdana',
              'chart.contextmenu':        null,
              'chart.units.pre':          '',
              'chart.units.post':         '',
              'chart.tooltips':           [],
              'chart.tooltips.effect':    'fade',
              'chart.tooltips.css.class': 'RGraph_tooltip',
              'chart.tooltips.highlight': true,
              'chart.highlight.stroke':   'black',
              'chart.highlight.fill':     'rgba(255,255,255,0.5)',
              'chart.annotatable':        false,
              'chart.annotate.color':     'black',
              'chart.zoom.mode':          'canvas',
              'chart.zoom.factor':        1.5,
              'chart.zoom.fade.in':       true,
              'chart.zoom.fade.out':      true,
              'chart.zoom.hdir':          'right',
              'chart.zoom.vdir':          'down',
              'chart.zoom.frames':        25,
              'chart.zoom.delay':         16.666,
              'chart.zoom.shadow':        true,
              'chart.zoom.background':    true,
              'chart.zoom.action':        'zoom',
              'chart.arrows':             false,
              'chart.margin':             0,
              'chart.resizable':              false,
              'chart.resize.handle.adjust':   [0,0],
              'chart.resize.handle.background': null,
              'chart.label.inner':        false,
              'chart.labels.count':       10,
              'chart.labels.position':    'right',
              'chart.adjustable':         false,
              'chart.min':                0,
              'chart.scale.decimals':     0,
              'chart.key':                [],
              'chart.key.background':     'white',
              'chart.key.position':       'graph',
              'chart.key.halign':             'right',
              'chart.key.shadow':         false,
              'chart.key.shadow.color':   '#666',
              'chart.key.shadow.blur':    3,
              'chart.key.shadow.offsetx': 2,
              'chart.key.shadow.offsety': 2,
              'chart.key.position.gutter.boxed': true,
              'chart.key.position.x':     null,
              'chart.key.position.y':     null,
              'chart.key.color.shape':    'square',
              'chart.key.rounded':        true,
              'chart.key.linewidth':      1
            },
            'Meter': {
              'chart.gutter.left':            25,
              'chart.gutter.right':           25,
              'chart.gutter.top':             25,
              'chart.gutter.bottom':          25,
              'chart.linewidth':              1,
              'chart.linewidth.segments':     1,
              'chart.strokestyle':            null,
              'chart.border':                 true,
              'chart.border.color':           'black',
              'chart.text.font':              'Verdana',
              'chart.text.size':              10,
              'chart.text.color':             'black',
              'chart.value.label':            false,
              'chart.value.text.decimals':    0,
              'chart.value.text.units.pre':   '',
              'chart.value.text.units.post':  '',
              'chart.title':                  '',
              'chart.title.background':       null,
              'chart.title.hpos':             null,
              'chart.title.vpos':             null,
              'chart.title.color':            'black',
              'chart.title.bold':             true,
              'chart.title.font':             null,
              'chart.green.start':            0,
              'chart.green.end':              33,
              'chart.green.color':            '#207A20',
              'chart.yellow.start':           33,
              'chart.yellow.end':             66,
              'chart.yellow.color':           '#D0AC41',
              'chart.red.start':              66,
              'chart.red.end':                100,
              'chart.red.color':              '#9E1E1E',
              'chart.units.pre':              '',
              'chart.units.post':             '',
              'chart.contextmenu':            null,
              'chart.zoom.factor':            1.5,
              'chart.zoom.fade.in':           true,
              'chart.zoom.fade.out':          true,
              'chart.zoom.hdir':              'right',
              'chart.zoom.vdir':              'down',
              'chart.zoom.frames':            25,
              'chart.zoom.delay':             16.666,
              'chart.zoom.shadow':            true,
              'chart.zoom.mode':              'canvas',
              'chart.zoom.thumbnail.width':   75,
              'chart.zoom.thumbnail.height':  75,
              'chart.zoom.background':        true,
              'chart.zoom.action':            'zoom',
              'chart.annotatable':            false,
              'chart.annotate.color':         'black',
              'chart.shadow':                 false,
              'chart.shadow.color':           'rgba(0,0,0,0.5)',
              'chart.shadow.blur':            3,
              'chart.shadow.offsetx':         3,
              'chart.shadow.offsety':         3,
              'chart.resizable':              false,
              'chart.resize.handle.adjust':   [0,0],
              'chart.resize.handle.background': null,
              'chart.tickmarks.small.num':      100,
              'chart.tickmarks.big.num':        10,
              'chart.tickmarks.small.color':    '#bbb',
              'chart.tickmarks.big.color':      'black',
              'chart.scale.decimals':           0,
              'chart.radius':                   null,
              'chart.centerx':                  null,
              'chart.centery':                  null,
              'chart.labels':                   true,
              'chart.segment.radius.start':     null,
              'chart.needle.radius':            null,
              'chart.needle.tail':              false
            },
            'Odometer': {
              'chart.radius':                 null,
              'chart.value.text':             false,
              'chart.value.text.decimals':    0,
              'chart.needle.color':           'black',
              'chart.needle.width':           2,
              'chart.needle.head':            true,
              'chart.needle.tail':            true,
              'chart.needle.type':            'pointer',
              'chart.needle.extra':            [],
              'chart.needle.triangle.border': '#aaa',
              'chart.text.size':              10,
              'chart.text.color':             'black',
              'chart.text.font':              'Verdana',
              'chart.green.max':              30,
              'chart.red.min':                50,
              'chart.green.color':            'green',
              'chart.yellow.color':           'yellow',
              'chart.red.color':              'red',
              'chart.green.solid':            false,
              'chart.yellow.solid':           false,
              'chart.red.solid':              false,
              'chart.label.area':             35,
              'chart.gutter.left':            25,
              'chart.gutter.right':           25,
              'chart.gutter.top':             25,
              'chart.gutter.bottom':          25,
              'chart.title':                  '',
              'chart.title.background':       null,
              'chart.title.hpos':             null,
              'chart.title.vpos':             null,
              'chart.title.font':             null,
              'chart.title.bold':             true,
              'chart.contextmenu':            null,
              'chart.linewidth':              1,
              'chart.shadow.inner':           false,
              'chart.shadow.inner.color':     'black',
              'chart.shadow.inner.offsetx':   3,
              'chart.shadow.inner.offsety':   3,
              'chart.shadow.inner.blur':      6,
              'chart.shadow.outer':           false,
              'chart.shadow.outer.color':     '#666',
              'chart.shadow.outer.offsetx':   0,
              'chart.shadow.outer.offsety':   0,
              'chart.shadow.outer.blur':      15,
              'chart.annotatable':            false,
              'chart.annotate.color':         'black',
              'chart.scale.decimals':         0,
              'chart.zoom.factor':            1.5,
              'chart.zoom.fade.in':           true,
              'chart.zoom.fade.out':          true,
              'chart.zoom.hdir':              'right',
              'chart.zoom.vdir':              'down',
              'chart.zoom.frames':            25,
              'chart.zoom.delay':             16.666,
              'chart.zoom.shadow':            true,
              'chart.zoom.mode':              'canvas',
              'chart.zoom.thumbnail.width':   75,
              'chart.zoom.thumbnail.height':  75,
              'chart.zoom.background':        true,
              'chart.zoom.action':            'zoom',
              'chart.resizable':              false,
              'chart.resize.handle.adjust':   [0,0],
              'chart.resize.handle.background': null,
              'chart.units.pre':              '',
              'chart.units.post':             '',
              'chart.border':                 false,
              'chart.border.color1':          '#BEBCB0',
              'chart.border.color2':          '#F0EFEA',
              'chart.border.color3':          '#BEBCB0',
              'chart.tickmarks.highlighted':  false,
              'chart.zerostart':              false,
              'chart.labels':                 null,
              'chart.units.pre':              '',
              'chart.units.post':             '',
              'chart.value.units.pre':        '',
              'chart.value.units.post':       '',
              'chart.key':                    [],
              'chart.key.background':         'white',
              'chart.key.position':           'graph',
              'chart.key.shadow':             false,
              'chart.key.shadow.color':       '#666',
              'chart.key.shadow.blur':        3,
              'chart.key.shadow.offsetx':     2,
              'chart.key.shadow.offsety':     2,
              'chart.key.position.gutter.boxed': true,
              'chart.key.position.x':         null,
              'chart.key.position.y':         null,
              'chart.key.halign':             'right',
              'chart.key.color.shape':        'square',
              'chart.key.rounded':            true,
              'chart.key.text.size':          10,
            }
        }
    };
    this.conf = apply(this.conf, config);
    this.create(this.conf)
    var oThis = this;
    //canvas creation takes some time, so we have to wait, until the element is available
    function check(){
        if (document.getElementById(oThis.conf.tmpId)) 
            oThis.setConfig(oThis.conf, viewPortCall);
        else 
            window.setTimeout(check, 100);
    }
    window.setTimeout(check, 100);
    return this;
}

HAP.Chart5.prototype.create = function(conf){
    this.div = document.createElement('canvas');
    this.div.id = this.conf.tmpId;
    return this.div;
}

HAP.Chart5.prototype.setConfig = function(conf, viewPortCall){
    this.conf = conf;
    this.div.style.position = 'absolute';
    this.div.style.width = this.conf.display['width'] + 'px';
    this.div.style.height = this.conf.display['height'] + 'px';
    
    if (!viewPortCall) {
        this.div.style.left = this.conf.display['x'] + 'px';
        this.div.style.top = this.conf.display['y'] + 'px';
    }
    
    if (document.getElementById(this.conf.tmpId)) {
        if (this.chart && viewPortCall) {
            RGraph.Clear(this.chart.canvas);
            var p = this.div.getParent();
            p.removeChild(document.getElementById(this.conf.tmpId));
            p.appendChild(this.create());
        }
        var type = this.conf.display['Chart-Type'];
        this.chart = new RGraph[type](this.conf.tmpId, [1, 2, 3]);
        this.chart.canvas.width = this.conf.display['width'];
        this.chart.canvas.height = this.conf.display['height'];
        
        
        // Prevent Javascript-failure
        if (type == 'HProgress' || type == 'VProgress') 
            this.chart.max = 100;
        if (type == 'Meter') {
            this.chart.min = 0;
            this.chart.max = 100;
            this.chart.value = 0;
        }
        if (type == 'Odometer') {
            this.chart.start = 0;
            this.chart.end = 100;
            this.chart.value = 0;
        }
        
        // To optimize : set properties directly not via loop !
        for (var prop in this.conf.display.chart[type]) {
            var val = this.conf.display.chart[type][prop];
            this.chart.Set(prop, val);
        }
        
        // set datasource props
        var size = this.conf.display.dataSources.length;
        for (var i = 0; i < size; i++) {
            var cObj = this.conf.display.dataSources[i];
            for (var cProp in cObj) {
                if (this.conf.display.chart[type][cProp] instanceof Array && this.conf.display.dataSources[i][cProp]) {
                    if (i == 0) 
                        this.conf.display.chart[type][cProp] = [];
                    this.conf.display.chart[type][cProp].push(this.conf.display.dataSources[i][cProp]);
                    this.chart.Set(cProp, this.conf.display.chart[type][cProp]);
                }
            }
        }
        if (viewPortCall) 
            this.fillChartData(this.conf.display.dataSources, viewPortCall);
    }
    this.div.style.zIndex = this.conf.display['z-Index'];
}

HAP.Chart5.prototype.fillChartData = function(dataSources, viewPortCall){
    var oThis = this;
    if (viewPortCall) {
        Ext.Ajax.request({
            url: 'gui/getChartData',
            params: {
                'data': Ext.encode(dataSources),
                'startOffset': this.conf.display['Start-Offset (m)'],
                'xSkip': this.conf.display['Chart-X-Interval'],
                'type': this.conf.display['Chart-Type'],
                'interval': this.conf.display['Interval (m)']
            },
            success: function(res, req){
                var data = Ext.decode(res.responseText).data;
                process(data);
            }
        });
    }
    else {
        YAHOO.util.Connect.asyncRequest('POST', '/gui/getChartData', {
            success: function(o){
                if (YAHOO.lang.JSON.isValid(o.responseText)) {
                    var response = YAHOO.lang.JSON.parse(o.responseText);
                    if (response.success) {
                        var data = response.data;
                        process(data);
                    }
                }
            }
        }, 'data=' + YAHOO.lang.JSON.stringify(dataSources) + '&startOffset=' + this.conf.display['Start-Offset (m)'] + '&xSkip=' + this.conf.display['Chart-X-Interval'] + '&type=' + this.conf.display['Chart-Type'] + '&interval=' + this.conf.display['Interval (m)']);
    }
    function process(data){
        if (!data) { //some dummy data
            data = {
                labels: ['a', 'b', 'c'],
                values: [[1, 2, 3]],
                min: 0,
                max: 100,
                start: 0,
                end: 100,
                value: 1
            };
        }
        RGraph.Clear(oThis.chart.canvas);
        oThis.chart.Set('chart.labels', data.labels);
        
        switch (oThis.conf.display['Chart-Type']) {
            case 'Line':
                oThis.chart.original_data = data.values;
                break;
            case 'Bar':
                oThis.chart.data = data.values;
                break;
            case 'HBar':
                oThis.chart.data = data.values;
                break;
            case 'HProgress':
                oThis.chart.value = data.value;
                oThis.chart.max = data.max;
                break;
            case 'VProgress':
                oThis.chart.value = data.value;
                oThis.chart.max = data.max;
                break;
            case 'Odometer':
                oThis.chart.start = data.start;
                oThis.chart.end = data.end;
                oThis.chart.value = data.value;
                break;
            case 'Meter':
                oThis.chart.min = data.min;
                oThis.chart.max = data.max;
                oThis.chart.value = data.value;
                break;
        }
        oThis.chart.Draw();
    }
}

HAP.Chart5.prototype.setValue = function(){
    this.fillChartData(this.conf.display.dataSources, false);
}

HAP.Chart5.prototype.attachEvent = function(event, handler, viewPortCall){
    if (!viewPortCall && event == 'onclick') {
        this.layer.onclick = handler;
    }
}

HAP.Chart5.prototype.setWidth = function(width){
    this.conf.display['width'] = width;
    this.div.style.width = width + 'px';
    if (this.chart) {
        RGraph.Clear(this.chart.canvas);
        this.chart.canvas.width = width;
        this.chart.Draw();
    }
}

HAP.Chart5.prototype.setHeight = function(height){
    this.conf.display['height'] = height;
    this.div.style.height = height + 'px';
    if (this.chart) {
        RGraph.Clear(this.chart.canvas);
        this.chart.canvas.height = height;
        this.chart.Draw();
    }
}

HAP.Chart5.prototype.setX = function(x, viewPortCall){
    this.conf.display['x'] = x;
    if (!viewPortCall) {
        this.div.style.left = x + 'px';
    }
}

HAP.Chart5.prototype.setY = function(y, viewPortCall){
    this.conf.display['y'] = y;
    if (!viewPortCall) {
        this.div.style.top = y + 'px';
    }
}

HAP.Chart5.prototype.setRequest = function(value){
}

HAP.Chart5Image = function(conf){
    this.conf = conf;
    this.conf.imagePath = '/static/images/gui/';
    var div = document.createElement('div');
    div.id = this.conf.id;
    div.style.height = this.conf.height + 'px';
    div.style.width = this.conf.width + 'px';
    div.style.top = this.conf.top + 'px';
    div.style.left = this.conf.left + 'px';
    div.style.textAlign = 'center';
    div.style.position = 'absolute';
    
    var img = document.createElement('img');
    img.src = this.conf.imagePath + 'Chart_60x60.png';
    img.style.textAlign = 'center'; // required for d&d
    div.appendChild(img);
    
    var textDiv = document.createElement('div');
    textDiv.style.fontSize = '10px';
    textDiv.style.textAlign = 'center'; // required for d&d
    textDiv.innerHTML = this.conf.name;
    div.appendChild(textDiv);
    
    return div;
}
