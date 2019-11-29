require 'spec_helper'

describe do
  before do
    seed_data
  end

  feature "contact" do
    scenario "should have the contact email" do
      visit "/contact"
      expect(page).to have_text("hello@agreelist.org")
    end
  end

  feature "faq" do
    scenario "should have the contact email" do
      visit "/faq"
      expect(page).to have_text("hello@agreelist.org")
    end
  end

  private

  def seed_data
    create(:statement)
    create(:individual, twitter: "arpahector", name: "Hector Perez", email: "hecpeare@gmail.com")
  end
end
