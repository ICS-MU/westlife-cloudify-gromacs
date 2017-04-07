define(_NODE_SERVER_,       ifdef(`_CFM_',`example.nodes.MonitoredServer',`example.nodes.Server'))dnl
define(_NODE_TORQUESERVER_, ifdef(`_CFM_',`example.nodes.MonitoredTorqueServer',`example.nodes.TorqueServer'))dnl
define(_NODE_WEBSERVER_,    ifdef(`_CFM_',`example.nodes.MonitoredWebServer', `example.nodes.WebServer'))dnl
define(_NODE_DBMS_,         ifdef(`_CFM_',`example.nodes.MonitoredDBMS', `example.nodes.DBMS'))dnl
define(_WORKERS_MIN_,       1)
define(_WORKERS_MAX_,       3)
