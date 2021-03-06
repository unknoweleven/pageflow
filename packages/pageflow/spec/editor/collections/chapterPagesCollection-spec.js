import {Chapter, PagesCollection, Page} from '$pageflow/editor';

describe('ChapterPagesCollection', () => {
  it('filters pages by chapter', () => {
    var pages = new PagesCollection([
      new Page({chapter_id: 1}),
      new Page({chapter_id: 2})
    ]);
    var chapter = new Chapter({id: 1}, {pages: pages});

    expect(chapter.pages.models).toEqual([pages.first()]);
  });

  it('sets reference back to chapter on create', () => {
    var pages = new PagesCollection([
      new Page({chapter_id: 1})
    ]);
    var chapter = new Chapter({id: 1}, {pages: pages});

    expect(chapter.pages.first().chapter).toBe(chapter);
  });

  it('sets reference back to chapter on add', () => {
    var pages = new PagesCollection([]);
    var page = new Page({chapter_id: 1});
    var chapter = new Chapter({id: 1}, {pages: pages});

    chapter.pages.add(page);

    expect(chapter.pages.first().chapter).toBe(chapter);
  });
});
