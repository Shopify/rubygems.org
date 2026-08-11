# frozen_string_literal: true

require "test_helper"

class Rubygems::VersionsTest < ActionDispatch::IntegrationTest
  setup do
    @rubygem = create(:rubygem, name: "sandworm", number: "1.0.0")
    @version = @rubygem.versions.first
  end

  test "anonymous versions index sets public cache headers" do
    get rubygem_versions_path(@rubygem.slug)

    assert_response :success
    assert_nil response.headers["Set-Cookie"]
    assert_includes response.headers["Cache-Control"], "public"
    assert_includes response.headers["Surrogate-Control"], "max-age=60"
    assert_equal "gem/sandworm/versions", response.headers["Surrogate-Key"]
  end

  test "anonymous version show sets public cache headers" do
    get rubygem_version_path(@rubygem.slug, @version.slug)

    assert_response :success
    assert_nil response.headers["Set-Cookie"]
    assert_includes response.headers["Cache-Control"], "public"
    assert_includes response.headers["Surrogate-Control"], "max-age=60"
    assert_equal "gem/sandworm", response.headers["Surrogate-Key"]
  end

  test "version navigation links resolve when adjacent versions are platformed or content-addressable" do
    platformed = create(:version, rubygem: @rubygem, number: "2.0.0", platform: "x86_64-linux-musl", gem_platform: "x86_64-linux-musl",
                        required_ruby_version: ">= 3.2")
    addressed = create(:version, rubygem: @rubygem, number: "3.0.0", platform: "x86_64-linux-musl", gem_platform: "x86_64-linux-musl",
                       required_ruby_version: "~> 3.4.0", ruby_abi: "3.4", sha256: Digest::SHA2.base64digest("sandworm-3.0.0-3.4"))

    get rubygem_version_path(@rubygem.slug, platformed.slug)

    assert_response :success
    doc = response.parsed_body

    assert_equal rubygem_version_path(@rubygem.slug, @version.slug), doc.at_css(".gem__previous__version")["href"]
    assert_equal rubygem_version_path(@rubygem.slug, addressed.slug), doc.at_css(".gem__next__version")["href"]

    get doc.at_css(".gem__next__version")["href"]

    assert_response :success
    assert_equal rubygem_version_path(@rubygem.slug, platformed.slug),
      response.parsed_body.at_css(".gem__previous__version")["href"]
  end
end
