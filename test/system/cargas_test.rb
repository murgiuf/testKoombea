require "application_system_test_case"

class CargasTest < ApplicationSystemTestCase
  setup do
    @carga = cargas(:one)
  end

  test "visiting the index" do
    visit cargas_url
    assert_selector "h1", text: "Cargas"
  end

  test "creating a Carga" do
    visit cargas_url
    click_on "New Carga"

    fill_in "Archivo", with: @carga.archivo
    fill_in "Estado", with: @carga.estado
    fill_in "User", with: @carga.user_id
    click_on "Create Carga"

    assert_text "Carga was successfully created"
    click_on "Back"
  end

  test "updating a Carga" do
    visit cargas_url
    click_on "Edit", match: :first

    fill_in "Archivo", with: @carga.archivo
    fill_in "Estado", with: @carga.estado
    fill_in "User", with: @carga.user_id
    click_on "Update Carga"

    assert_text "Carga was successfully updated"
    click_on "Back"
  end

  test "destroying a Carga" do
    visit cargas_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Carga was successfully destroyed"
  end
end
