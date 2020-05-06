const meta = require('./shaders/meta.json')
const list = meta.list

const generate = {
  routes() {
    return list.map((name) => `detail/${name}`)
  }
}

module.exports = generate
