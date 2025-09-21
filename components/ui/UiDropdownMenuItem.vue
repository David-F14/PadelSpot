<template>
  <DropdownMenuItem
    v-bind="delegatedProps"
    :class="cn(
      'relative flex cursor-default select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none transition-colors focus:bg-accent focus:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50',
      inset && 'pl-8',
      props.class
    )"
  >
    <slot />
  </DropdownMenuItem>
</template>

<script setup lang="ts">
import { type HTMLAttributes, computed } from 'vue'
import {
  DropdownMenuItem,
} from 'radix-vue'
import { cn } from '~/lib/utils'

interface Props {
  class?: HTMLAttributes['class'] | string
  inset?: boolean
  disabled?: boolean
  asChild?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  inset: false
})

const delegatedProps = computed(() => {
  const { class: _, inset: __, ...delegated } = props
  return delegated
})
</script>