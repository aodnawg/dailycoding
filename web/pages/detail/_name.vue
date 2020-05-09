<template>
  <div class="row">
    <DetailView :shader="source" :name="name" />
  </div>
</template>

<style>
#code {
  white-space: pre-wrap;
}
.row {
  margin: 0 16px;
}
</style>

<script lang="ts">
import { Vue, Component, Prop } from 'vue-property-decorator'
import DetailView from '~/components/DetailView/DetailView.vue'

const asyncData = async ({ params }: any) => {
  const metaData = require('../../shaders/list.json')
  const jsonData = require(`../../shaders/${params.name}.json`)
  return { source: jsonData.body, title: 'haga', name: params.name }
}

export default {
  components: { DetailView },
  asyncData
}
</script>
