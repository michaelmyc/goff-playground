<script setup lang="ts">
import { ref, onMounted, watch } from "vue";
import { v4 as uuidv4 } from "uuid";
// @ts-expect-error
import CodeEditor from "simple-code-editor";

// Define props
const props = defineProps<{
  proxyUrl?: string;
}>();

// Define emits
const emit = defineEmits<{
  (e: "update:proxyUrl", value: string): void;
  (e: "evaluate", data: any): void;
}>();

// Form data
const formData = ref({
  flagName: "",
  flagType: "boolean" as "boolean" | "string" | "number" | "object",
  defaultValue: "false",
  targetingKey: "",
  context: "{}",
});

// Error states
const contextError = ref<string | null>(null);
const defaultValueError = ref<string | null>(null);

// Initialize targeting key on component mount
onMounted(() => {
  formData.value.targetingKey = uuidv4();
});

// Watch for flag type changes to update default value
watch(
  () => formData.value.flagType,
  (newType) => {
    switch (newType) {
      case "boolean":
        formData.value.defaultValue = "false";
        break;
      case "string":
        formData.value.defaultValue = "";
        break;
      case "number":
        formData.value.defaultValue = "0";
        break;
      case "object":
        formData.value.defaultValue = "{}";
        break;
    }
    // Clear any previous default value errors when type changes
    defaultValueError.value = null;
  },
);

// Validate default value based on flag type
const validateDefaultValue = () => {
  defaultValueError.value = null;

  switch (formData.value.flagType) {
    case "boolean":
      if (
        formData.value.defaultValue !== "true" &&
        formData.value.defaultValue !== "false"
      ) {
        defaultValueError.value =
          'Boolean default value must be "true" or "false"';
        return false;
      }
      break;
    case "number":
      if (isNaN(Number(formData.value.defaultValue))) {
        defaultValueError.value = "Number default value must be a valid number";
        return false;
      }
      break;
    case "object":
      try {
        JSON.parse(formData.value.defaultValue);
      } catch (e) {
        defaultValueError.value = "Object default value must be valid JSON";
        return false;
      }
      break;
  }
};

const validateAndParseContext = (): any => {
  if (formData.value.context.trim() !== "") {
    try {
      return JSON.parse(formData.value.context);
    } catch (e) {
      contextError.value = "Invalid JSON format in context attributes";
      return;
    }
  }
  return {};
};

// Handle form submission
const handleSubmit = () => {
  // Reset errors
  contextError.value = null;
  defaultValueError.value = null;

  // Validate default value
  validateDefaultValue();

  // Validate and parse the context JSON
  const contextObj = validateAndParseContext();

  if (contextError.value || defaultValueError.value) {
    return;
  }

  // Parse default value based on flag type
  let parsedDefaultValue: any = formData.value.defaultValue;
  if (formData.value.flagType === "boolean") {
    parsedDefaultValue = formData.value.defaultValue === "true";
  } else if (formData.value.flagType === "number") {
    parsedDefaultValue = Number(formData.value.defaultValue);
  } else if (formData.value.flagType === "object") {
    try {
      parsedDefaultValue = JSON.parse(formData.value.defaultValue);
    } catch (e) {
      // This shouldn't happen since we validated above, but just in case
      parsedDefaultValue = {};
    }
  }

  emit("evaluate", {
    flagName: formData.value.flagName,
    flagType: formData.value.flagType,
    defaultValue: parsedDefaultValue,
    targetingKey: formData.value.targetingKey,
    context: contextObj,
  });
};

// Expose the handleSubmit method to parent components
defineExpose({
  handleSubmit,
});
</script>

<template>
  <div class="flag-input">
    <h2>Flag Configuration</h2>

    <div class="form-group">
      <label for="proxyUrl">Proxy URL:</label>
      <input
        id="proxyUrl"
        type="text"
        :value="props.proxyUrl"
        @input="
          $emit('update:proxyUrl', ($event.target as HTMLInputElement).value)
        "
        placeholder="http://localhost:1031"
      />
    </div>

    <div class="form-group">
      <label for="flagName">Flag Name:</label>
      <input
        id="flagName"
        type="text"
        v-model="formData.flagName"
        placeholder="Enter flag name"
        required
      />
    </div>

    <div class="form-group">
      <label for="flagType">Flag Type:</label>
      <select id="flagType" v-model="formData.flagType">
        <option value="boolean">Boolean</option>
        <option value="string">String</option>
        <option value="number">Number</option>
        <option value="object">Object</option>
      </select>
    </div>

    <div class="form-group">
      <label for="defaultValue">Default Value:</label>
      <input
        id="defaultValue"
        type="text"
        v-model="formData.defaultValue"
        placeholder="Enter default value"
      />
      <div v-if="defaultValueError" class="error-message">
        {{ defaultValueError }}
      </div>
    </div>

    <div class="form-group">
      <label for="targetingKey">Targeting Key:</label>
      <input
        id="targetingKey"
        type="text"
        v-model="formData.targetingKey"
        placeholder="Enter targeting key"
      />
      <button
        type="button"
        @click="formData.targetingKey = uuidv4()"
        class="generate-btn"
      >
        Generate UUID
      </button>
    </div>

    <div class="form-group">
      <label for="context">Context Attributes (JSON):</label>
      <CodeEditor
        v-model="formData.context"
        :languages="[['json', 'JSON']]"
        :header="false"
        theme="github"
        padding="10px"
        width="100%"
        font-size="13px"
        border-radius="4px"
      />
      <div v-if="contextError" class="error-message">
        {{ contextError }}
      </div>
    </div>

    <button @click="handleSubmit" class="evaluate-btn">Evaluate Flag</button>
    <p class="shortcut-hint">Tip: Press Ctrl/Cmd + Enter to evaluate flag</p>
  </div>
</template>
