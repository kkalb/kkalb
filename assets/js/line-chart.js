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
        borderColor: corange,
        backgroundColor: csilver
      }]
    };

    Chart.defaults.color = cwhite;

    this.chart = new Chart(ctx, {
      type: "line",
      data: data,
      options: {
        animations: {
          tension: {
            duration: 800,
            easing: 'easeInSine',
            from: 0.1,
            to: 0.7,
            loop: true
          }
        },
        responsive: true,
        // default is true
        maintainAspectRatio: false,
        plugins: {
          title: {
            display: true,
            text: title,
          },
          legend: {
            display: true,
            position: "top",
            labels: {
              color: cwhite,
              font: {
                color: cwhite
              }
            }
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
