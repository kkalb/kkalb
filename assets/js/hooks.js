import LineChart from "./line-chart";
import flatpickr from "flatpickr";

let Hooks = {};

// LineChart handles the initialisation and update of the line chart
Hooks.LineChart = {
  // Called once when a new chart is mounted
  mounted() {
    const { labels } = JSON.parse(this.el.dataset.chartLabels);
    const { values } = JSON.parse(this.el.dataset.chartValues);
    const { headings } = JSON.parse(this.el.dataset.chartHeadings);
    const { title } = JSON.parse(this.el.dataset.chartTitle);

    this.chart = new LineChart(this.el, labels, values, headings, title);

    this.handleEvent("new-point", ({ label, value, id }) => {
      if (this.chart.chart.canvas.id == id) {
        this.chart.addPoint(label, value);
      }
    });
  },
  // Called everytime the data changes
  updated() {
    let chart = this.chart.chart;
    chart.destroy();

    const { labels } = JSON.parse(this.el.dataset.chartLabels);
    const { values } = JSON.parse(this.el.dataset.chartValues);
    const { headings } = JSON.parse(this.el.dataset.chartHeadings);
    const { title } = JSON.parse(this.el.dataset.chartTitle);

    this.chart = new LineChart(this.el, labels, values, headings, title);
  },
};

Hooks.Pickr = {
  mounted() {
    this.initPickr()
  },
  updated() {
    this.initPickr()
  },
  initPickr() {
    flatpickr(this.el, {
      enableTime: false,
      dateFormat: "Y-m-d",
      onChange: this.handleDateChange.bind(this),
      defaultDate: this.el.dataset.date,
      maxDate: new Date().toISOString().slice(0, 10)
    });
  },
  handleDateChange(selectedDates, dateStr, instance) {
    this.pushEvent("date_selected", { date: dateStr });
  }
}


export default Hooks;
