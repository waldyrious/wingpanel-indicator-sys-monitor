public class SysMonitor.Indicator : Wingpanel.Indicator {
    const string APPNAME = "wingpanel-indicator-sys-monitor";
    private SysMonitor.Services.CPU cpu;
    private SysMonitor.Services.Memory memory;

    private SysMonitor.Widgets.DisplayWidget display_widget;
    private SysMonitor.Widgets.PopoverWidget popover_widget;


    public Indicator (Wingpanel.IndicatorManager.ServerType server_type) {
        Object (code_name: APPNAME,
                display_name: _("Sys-Monitor"),
                description: _("System monitor indicator that display CPU and RAM usage in wingpanel"));

        this.cpu = new SysMonitor.Services.CPU();
        this.memory = new SysMonitor.Services.Memory();

        visible = true;

        this.update_display_widget();
    }

    public override Gtk.Widget get_display_widget () {
        if (this.display_widget == null) {
            this.display_widget = new SysMonitor.Widgets.DisplayWidget();
            this.update_display_widget();
        }
        return this.display_widget;
    }

    public override Gtk.Widget? get_widget () {
        if (popover_widget == null) {
            this.popover_widget = new SysMonitor.Widgets.PopoverWidget ();
        }

        return this.popover_widget;
    }

    public override void opened () {}

    public override void closed () {}

    private void update_display_widget () {
        if (this.display_widget != null) {
            Timeout.add_seconds (1, () => {
                this.display_widget.set_cpu(this.cpu.percentage_used);
                this.display_widget.set_mem(this.memory.percentage_used);

                this.popover_widget.update_memory_info(this.memory.used, this.memory.total);
                this.popover_widget.update_swap_info(this.memory.used_swap, this.memory.total_swap);
                return true;
            });
        }
    }
}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Loading system monitor indicator");

    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        debug ("Wingpanel is not in session, not loading sys-monitor");
        return null;
    }

    var indicator = new SysMonitor.Indicator (server_type);

    return indicator;
}
