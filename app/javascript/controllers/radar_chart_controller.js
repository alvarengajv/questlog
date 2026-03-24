import { Controller } from "@hotwired/stimulus"
import { Chart, RadarController, RadialLinearScale, PointElement, LineElement, Filler, Tooltip } from "chart.js"
Chart.register(RadarController, RadialLinearScale, PointElement, LineElement, Filler, Tooltip)

export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    labels: Array,
    values: Array
  }

  connect() {
    const styles = getComputedStyle(document.documentElement)
    this.questGold = styles.getPropertyValue('--color-quest-gold').trim()
    this.parchment = styles.getPropertyValue('--color-parchment').trim()
    this.#renderChart()
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }

  #hexToRgba(hex, alpha) {
    const r = parseInt(hex.slice(1, 3), 16)
    const g = parseInt(hex.slice(3, 5), 16)
    const b = parseInt(hex.slice(5, 7), 16)
    return `rgba(${r},${g},${b},${alpha})`
  }

  #renderChart() {
    const ctx = this.canvasTarget.getContext("2d")

    this.chart = new Chart(ctx, {
      type: "radar",
      data: {
        labels: this.labelsValue,
        datasets: [{
          data: this.valuesValue,
          backgroundColor: this.#hexToRgba(this.questGold, 0.2),
          borderColor: this.questGold,
          pointBackgroundColor: this.questGold,
          pointBorderColor: this.questGold,
          pointHoverBackgroundColor: "#fff",
          pointHoverBorderColor: this.questGold,
          borderWidth: 2
        }]
      },
      options: {
        responsive: false,
        maintainAspectRatio: false,
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
              color: this.#hexToRgba(this.questGold, 0.1)
            },
            angleLines: {
              color: this.#hexToRgba(this.questGold, 0.1)
            },
            pointLabels: {
              color: this.parchment,
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
