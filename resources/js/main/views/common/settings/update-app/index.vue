<template>
    <a-card class="page-content-container mt-20 mb-20">
        <a-row class="mt-20">
            <a-col :span="24">
                <a-alert
                    v-if="productStatus == 'fetching'"
                    type="info"
                    showIcon
                    :message="$t('messages.fetching_product_details')"
                >
                    <template #icon>
                        <SyncOutlined spin />
                    </template>
                    <span v-html="$t('messages.fetching_product_details')"></span>
                </a-alert>
                <a-alert
                    v-if="productStatus == 'success'"
                    type="success"
                    showIcon
                    :message="$t('messages.product_is_upto_date')"
                />
                <a-alert
                    v-if="productStatus == 'update_available'"
                    type="warning"
                    showIcon
                    :message="
                        $t('messages.new_app_version_avaialbe', [product.product.version])
                    "
                />

                <div class="table-responsive mt-10">
                    <a-table
                        :columns="tableColumns"
                        :row-key="(record) => record.id"
                        :data-source="appDetails"
                        :pagination="false"
                        :showHeader="false"
                    >
                        <template #bodyCell="{ column, record }">
                            <template v-if="column.dataIndex == 'name'">
                                <a-typography-title
                                    :level="5"
                                    v-if="record.name == 'app_details'"
                                    strong
                                >
                                    {{ $t(`update_app.app_details`) }}
                                </a-typography-title>
                                <span v-else>
                                    {{ $t(`update_app.${record.name}`) }}
                                </span>
                            </template>
                            <template v-if="column.dataIndex == 'value'">
                                <span v-if="record.name == 'vue_version'">
                                    {{ vueVersion }}
                                </span>
                                <span v-else>{{ record.value }}</span>
                            </template>
                        </template>
                    </a-table>
                </div>
            </a-col>
        </a-row>
    </a-card>
</template>

<script>
import { defineComponent, createVNode, ref, onMounted, version } from "vue";
import { Modal } from "ant-design-vue";
import { SyncOutlined, ExclamationCircleOutlined } from "@ant-design/icons-vue";
import axios from "axios";
import { useI18n } from "vue-i18n";
import { useStore } from "vuex";
import { getUrlByAppType } from "../../../../../common/scripts/functions";

export default defineComponent({
    components: {
        SyncOutlined,
    },
    setup() {
        const appDetails = ref([]);
        const vueVersion = version;
        const { t } = useI18n();
        const productStatus = ref("fetching");
        const product = ref([]);
        const store = useStore();

        const tableColumns = [
            {
                title: t("update_app.name"),
                dataIndex: "name",
                width: "40%",
            },
            {
                title: t("update_app.value"),
                dataIndex: "value",
            },
        ];

        onMounted(() => {
            axiosAdmin(getUrlByAppType("update-app")).then((response) => {
                const appVersion = response.data.app_version;
                appDetails.value = response.data.app_details;

                axios
                    .post("https://envato.codeifly.com/product", {
                        verified_name: window.config.product_name,
                        domain: window.location.host,
                    })
                    .then((res) => {
                        product.value = res.data;

                        if (product.value.product.other_domain_verified) {
                            Modal.confirm({
                                title: t("update_app.verify_failed"),
                                icon: createVNode(ExclamationCircleOutlined),
                                content: t("update_app.verified_with_other_domain"),
                                okText: t("update_app.verify_again"),
                                okType: "danger",
                                cancelButtonProps: {
                                    disabled: true,
                                },
                                onOk() {
                                    store.dispatch("auth/logoutToRootUrl");
                                },
                            });
                        } else if (!product.value.product.verified) {
                            Modal.confirm({
                                title: t("update_app.verify_failed"),
                                icon: createVNode(ExclamationCircleOutlined),
                                content: t("update_app.verify_failed_message"),
                                okText: t("update_app.verify_again"),
                                okType: "danger",
                                cancelButtonProps: {
                                    disabled: true,
                                },
                                onOk() {
                                    store.dispatch("auth/logoutToRootUrl");
                                },
                            });
                        } else if (product.value.product.version != appVersion) {
                            productStatus.value = "update_available";
                        } else {
                            productStatus.value = "success";
                        }
                    });
            });
        });

        const updateApp = () => {
            Modal.confirm({
                title: t("common.install"),
                icon: createVNode(ExclamationCircleOutlined),
                content: t("messages.are_you_sure_install_message"),
                okText: t("common.yes"),
                okType: "danger",
                cancelText: t("common.no"),
                onOk() {
                    installUpdateModalTitle.value = t("common.installing") + "...";

                    emit("install", props.module.verified_name);

                    installUpdateModalVisible.value = true;
                },
                onCancel() {},
            });
        };

        return {
            tableColumns,
            appDetails,
            vueVersion,
            productStatus,
            product,
            updateApp,
        };
    },
});
</script>
