<template>
    <a-button @click="refetchTranslations" :loading="loading" :style="{ width: '100%' }">
        <template #icon>
            <SyncOutlined />
        </template>
        {{ $t("translations.fetch_new_translations") }}
    </a-button>
</template>

<script>
import { defineComponent } from "vue";
import { SyncOutlined } from "@ant-design/icons-vue";
import { useI18n } from "vue-i18n";
import apiAdmin from "../../../../../common/composable/apiAdmin";
import { getUrlByAppType } from "../../../../../common/scripts/functions";

export default defineComponent({
    emits: ["fetchTranslationsSuccesss"],
    components: {
        SyncOutlined,
    },
    setup(props, { emit }) {
        const { addEditRequestAdmin, loading } = apiAdmin();
        const { t } = useI18n();

        const refetchTranslations = () => {
            addEditRequestAdmin({
                url: getUrlByAppType("translations/refetch"),
                data: {},
                successMessage: t("translations.fetched_successfully"),
                success: (res) => {
                    emit("fetchTranslationsSuccesss");
                },
            });
        };

        return {
            loading,
            refetchTranslations,
        };
    },
});
</script>

<style></style>
