# coding: utf-8
require 'spec_helper'

module Pageflow
  describe Theming do
    describe '#theme_name' do
      it 'is invalid if not registered' do
        theming = build(:theming, :theme_name => 'unknown')

        theming.valid?

        expect(theming.errors).to include(:theme_name)
      end

      it 'is invalid if disabled for account' do
        pageflow_configure do |config|
          config.features.register('glitter_theme') do |feature_config|
            feature_config.themes.register(:glitter)
          end
        end

        account = create(:account, feature_states: {glitter_theme: false})
        theming = build(:theming, account: account, theme_name: 'glitter')

        theming.valid?
        expect(theming.errors).to include(:theme_name)
      end

      it 'is valid if registered for usage in theming' do
        pageflow_configure do |config|
          config.themes.register(:custom)
        end

        theming = build(:theming, theme_name: 'custom')

        expect(theming).to be_valid
      end

      it 'is valid if enabled for account' do
        pageflow_configure do |config|
          config.features.register('glitter_theme') do |feature_config|
            feature_config.themes.register(:glitter)
          end
        end

        account = create(:account, feature_states: {glitter_theme: true})
        theming = build(:theming, account: account, theme_name: 'glitter')

        expect(theming).to be_valid
      end
    end

    describe '#theme' do
      it 'looks up theme by #theme_name' do
        pageflow_configure do |config|
          config.themes.register(:named_theme)
        end

        theming = build(:theming, theme_name: 'named_theme')

        expect(theming.theme.name).to eq('named_theme')
      end
    end

    describe '#cname_domain' do
      it 'removes subdomain' do
        theming = build(:theming, :cname => 'foo.bar.com')

        expect(theming.cname_domain).to eq('bar.com')
      end

      it 'removes multiple subdomain' do
        theming = build(:theming, :cname => 'foo.bar.baz.com')

        expect(theming.cname_domain).to eq('baz.com')
      end

      it 'does not change anything if no subdomain is present' do
        theming = build(:theming, :cname => 'foo.org')

        expect(theming.cname_domain).to eq('foo.org')
      end

      it 'does not change bogus' do
        theming = build(:theming, :cname => 'localhost')

        expect(theming.cname_domain).to eq('localhost')
      end

      it 'is empty if cname is empty' do
        theming = build(:theming, :cname => '')

        expect(theming.cname_domain).to eq('')
      end
    end

    describe '#copy_defaults_to' do
      let(:theming) { create(:theming) }
      let(:revision) { create(:revision) }

      it "updates the revision author with the theming's default author" do
        theming.update default_author: 'Amir Greithanner'

        theming.copy_defaults_to(revision)

        expect(revision.author).to eq('Amir Greithanner')
      end

      it "updates the revision publisher with the theming's default publisher" do
        theming.update default_publisher: 'Spöttel KG'

        theming.copy_defaults_to(revision)

        expect(revision.publisher).to eq('Spöttel KG')
      end

      it "updates the revision keywords with the theming's default keywords" do
        theming.update default_keywords: 'ratione, aut, blanditiis'

        theming.copy_defaults_to(revision)

        expect(revision.keywords).to eq('ratione, aut, blanditiis')
      end

      it "updates the revision home_button_enabled with the theming's home_button_enabled_by_"\
         'default' do
        theming.update home_button_enabled_by_default: true

        theming.copy_defaults_to(revision)

        expect(revision.home_button_enabled).to eq(true)
      end

      it "updates the revision theme_name with the theming's default theme_name" do
        Pageflow.config.themes.register(:acme_corp)

        theming.update theme_name: 'acme_corp'

        theming.copy_defaults_to(revision)

        expect(revision.theme_name).to eq('acme_corp')
      end
    end

    describe '.with_home_url' do
      it 'includes theming with home_url' do
        theming = create(:theming, home_url: 'http://home.example.com')

        expect(Theming.with_home_url).to include(theming)
      end

      it 'does not include theming with blank home_url' do
        theming = create(:theming, home_url: '')

        expect(Theming.with_home_url).not_to include(theming)
      end
    end

    describe '.for_request' do
      it 'uses Pageflow.config.theming_request_scope' do
        Pageflow.config.theming_request_scope = lambda do |themings, request|
          themings.where(cname: request.subdomain)
        end
        matching_theming = create(:theming, cname: 'matching')
        other_theming = create(:theming, cname: 'other')
        request = double('Request', subdomain: 'matching')

        result = Theming.for_request(request)

        expect(result).to eq([matching_theming])
      end
    end

    describe '#share_providers' do
      it 'converts array of share providers to a config hash stored as default_share_providers' do
        theming = build(:theming, share_providers: %w[facebook twitter])

        expect(theming.default_share_providers).to eq('facebook' => true, 'twitter' => true)
      end

      it 'returns the share_providers as array' do
        theming = build(:theming, share_providers: %w[facebook twitter])

        expect(theming.share_providers).to eq([['facebook', true], ['twitter', true]])
      end
    end

    describe '#default_share_providers' do
      it 'falls back to default_share_providers specified in config if none are given' do
        theming = build(:theming)

        expect(theming.default_share_providers).to eq(
          'email' => true,
          'facebook' => true,
          'linked_in' => true,
          'telegram' => true,
          'twitter' => true,
          'whats_app' => true
         )
      end
    end
  end
end
