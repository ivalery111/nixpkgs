{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,

  # dependencies
  google-auth,
  requests,

  # tests
  langchain-openai,
  openai,
  pyfakefs,
  pytestCheckHook,
  pytest-mock,
  requests-mock,
}:

buildPythonPackage rec {
  pname = "databricks-sdk";
  version = "0.49.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "databricks";
    repo = "databricks-sdk-py";
    tag = "v${version}";
    hash = "sha256-lNP3ETmRK6sRx9mP2JuIe/OcBbCDEvipST2LUjycgjs=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    google-auth
    requests
  ];

  pythonImportsCheck = [
    "databricks.sdk"
  ];

  nativeCheckInputs = [
    langchain-openai
    openai
    pyfakefs
    pytestCheckHook
    pytest-mock
    requests-mock
  ];

  disabledTests = [
    # Require internet access
    # ValueError: default auth: cannot configure default credentials, please check...
    "test_azure_cli_does_not_specify_tenant_id_with_msi"
    "test_azure_cli_fallback"
    "test_azure_cli_user_no_management_access"
    "test_azure_cli_user_with_management_access"
    "test_azure_cli_with_warning_on_stderr"
    "test_azure_cli_workspace_header_present"
    "test_config_azure_cli_host"
    "test_config_azure_cli_host_and_resource_id"
    "test_config_azure_cli_host_and_resource_i_d_configuration_precedence"
    "test_load_azure_tenant_id_404"
    "test_load_azure_tenant_id_happy_path"
    "test_load_azure_tenant_id_no_location_header"
    "test_load_azure_tenant_id_unparsable_location_header"
  ];

  __darwinAllowLocalNetworking = true;

  meta = {
    description = "Databricks SDK for Python";
    homepage = "https://github.com/databricks/databricks-sdk-py";
    changelog = "https://github.com/databricks/databricks-sdk-py/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
