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

const cdark = '#2D3142';
const csilver = '#BFC0C0';
const cwhite = '#FFFFFF';
const corange = '#EF8354';
const cgray = '#4F5D75';

Hooks.Canvas = {
  mounted() {
    console.log("mounted")
    let canvas = document.getElementById("big_canvas");
    let context = canvas.getContext("2d");

    context.lineWidth = 1;

    width = canvas.getAttribute('width');
    height = canvas.getAttribute('height');
    color = canvas.getAttribute('gridColor');

    context.strokeStyle = cwhite;
    context.fillStyle = cgray;
    context = this.drawBoard(context, width, height)
    const dpi = window.devicePixelRatio;
    context.scale(dpi, dpi);
    context.stroke();
    this.handleEvent("spawn", (payload) => this.spawn(payload))
  },

  drawBoard(context, width, height) {
    for (x = 0; x <= width; x += 10) {
      context.moveTo(0.5 + x, 0);
      context.lineTo(0.5 + x, height);
    }
    for (var y = 0; y <= height; y += 10) {
      context.moveTo(0, 0.5 + y);
      context.lineTo(width, 0.5 + y);
    }

    return context;
  },

  spawn(grid) {
    let canvas = document.getElementById("big_canvas");
    let context = canvas.getContext("2d");
    context = this.drawBoard(context, width, height);
    context.strokeStyle = cwhite;
    for (let row in grid) {
      for (let col in grid[row]) {
        val = grid[row][col]
        if (val == 'alive') {
          context.fillStyle = corange;
          context.fillRect(row * 10, col * 10, 10, 10);
        }
        else {
          context.fillStyle = cgray;
          context.fillRect(row * 10, col * 10, 10, 10);
        }
      }
    }
    context.stroke();
  },
}

export default Hooks;
