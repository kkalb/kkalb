import {
  CategoryScale,
  Chart,
  Legend,
  LinearScale,
  LineController,
  LineElement,
  PointElement,
  Title,
  Tooltip,
} from "chart.js";

Chart.register(LineElement, LineController, PointElement, CategoryScale, LinearScale, Legend, Title, Tooltip);

// TODO import from tailwind js

const cdark = "#2D3142";
const csilver = "#BFC0C0";
const cwhite = "#FFFFFF";
const corange = "#EF8354";
const cgray = "#4F5D75";

class LineChart {
  constructor(ctx, labels, values, headings, title) {

    var data = {
      labels: labels,
      datasets: [{
        label: headings[0],
        data: values,
        fill: {value: 25},
        borderColor: corange,
      }]
    };
    
    this.chart = new Chart(ctx, {
      type: "line",
      data: data,
      options: {
        animations: {
          tension: {
            duration: 1000,
            easing: 'easeInSine',
            from: 0.6,
            to: 0.4,
            loop: true
          }
        },
        responsive: true,
        // default is true
        maintainAspectRatio: true,
        plugins: {
          title: {
            display: true,
            text: title,
          },
          legend: {
            display: false,
            position: "top",
          },
        },
      },
    });
  }
// used to update async. with new data point
  addPoint(label, value) {
    const labels = this.chart.data.labels;
    const data = this.chart.data.datasets[0].data;
    data.push(value);
    labels.push(label);
    this.chart.update();
  }
}

export default LineChart;
