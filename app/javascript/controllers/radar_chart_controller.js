import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js"

export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    labels: Array,
    values: Array
  }

  connect() {
    this.#renderChart()
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }

  #renderChart() {
    const ctx = this.canvasTarget.getContext("2d")

    this.chart = new Chart(ctx, {
      type: "radar",
      data: {
        labels: this.labelsValue,
        datasets: [{
          data: this.valuesValue,
          backgroundColor: "rgba(201,169,110,0.2)",
          borderColor: "rgb(201,169,110)",
          pointBackgroundColor: "rgb(201,169,110)",
          pointBorderColor: "rgb(201,169,110)",
          pointHoverBackgroundColor: "#fff",
          pointHoverBorderColor: "rgb(201,169,110)",
          borderWidth: 2
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
          legend: { display: false }
        },
        scales: {
          r: {
            beginAtZero: true,
            max: 100,
            ticks: {
              display: false
            },
            grid: {
              color: "rgba(201,169,110,0.1)"
            },
            angleLines: {
              color: "rgba(201,169,110,0.1)"
            },
            pointLabels: {
              color: "#f4e8d1",
              font: {
                size: 12
              }
            }
          }
        }
      }
    })
  }
}
