import graph from 'fbgraph';
import request from 'request-promise';
import franc from 'franc-min'
import logger from './logger';
import { FacebookProfile, FacebookPost, FacebookComment } from '../data/connectors';

/** @class FacebookCrawler 
 *  @param  {Object} config Config object which contains the Twitter API credentials
 *  @classdesc Class for crawling Facebook data
*/
export default class FacebookCrawler {

    constructor(config) {
        this.graph = graph;
        this.graph.setAccessToken("EAACEdEose0cBADQK3mQlb59RGZABbZCUdMkGcgescEhPSmaukZB94dom8HhLsp8Fv7BTkLklFSbJH54pZAgEvkcz0nvlZCCoRnXhsfXTPFZAfaZAxMPF5EnhGO8jzIbHOtoEATAsHQliZAQZCZBvzmltJpledr32FelxoUG2VYGB0vbqYfhttKx61xAZAKjmLchcZB5qxWWEIu5AKAZDZD")
        this.graph.setVersion("2.8");
    }

    /**
     * @function searchAndSaveFBPages
     * @param  {String} keyword Keyword for searching Facebook pages
     * @description Searches for Facebook pages which match the keyword. It also inserts the found pages and their posts into the database. 
     * Only pages with matching categories (.env file config) are saved.
     * @see File /server/.env
     * @memberof FacebookCrawler
     * @return {void} 
     */
    searchAndSaveFBPages(keyword) {
        logger.info("Started Facebook search");
        var pages = new Array();
        var searchOptions = {
            q: keyword,
            type: "page",
            fields: "name,id,feed{id,link,message,story,likes,comments{id,message},created_time},category"
        }

        graph.search(searchOptions, async (err, res) => {

            pages.push(...res.data)
            var latestRes = res;

            while (latestRes.paging && latestRes.paging.next) {
                var newRes = await this.resolveResponse(err, latestRes)
                pages.push(...newRes.data);
                latestRes = newRes;
            }

            // Filter pages to only get the ones with the right category
            var filteredPages = pages.filter((page) => {
                return process.env.FACEBOOK_PAGE_CATEGORY_FILTER.split(",").includes(page.category)
            });

            //Start inserting pages and posts into the db
            //profile --> posts --> comments
            filteredPages.forEach(async page => {
                page.type = "page";
                page.keyword = keyword;

                var posts = new Array();

                if (page.feed) {
                    posts.push(...page.feed.data);

                    var latestFeed = page.feed;
                    while (latestFeed.paging && latestFeed.paging.next) {
                        var newFeed = await this.resolveResponse(err, latestFeed);
                        posts.push(...newFeed.data);
                        latestFeed = newFeed;
                    }
                    FacebookProfile.upsert({
                        id: page.id,
                        name: page.name,
                        category: page.category,
                        type: page.type,
                        keyword: page.keyword
                    }).then(created => { // created is an boolean indicating whether the instance was created (1) or updated (0)
                        FacebookProfile.findOne({
                            where: {
                                id: page.id
                            }
                        }).then(profile => {
                            posts.forEach(post => {
                                FacebookPost.upsert({
                                    id: post.id,
                                    message: post.message,
                                    lang: franc(post.message),
                                    story: post.story,
                                    link: post.link,
                                    created: post.created_time,
                                    FBProfileId: profile.id
                                }).then(created => {
                                    FacebookPost.findOne({
                                        where: {
                                            id: post.id
                                        }
                                    }).then(async dbPost => {
                                        var comments = new Array();
                                        comments.push(...post.comments.data);
                                        console.log(comments);
                                        var latestCommentFeed = post.comments.data
                                        while (latestCommentFeed.paging && latestCommentFeed.paging.next) {
                                            var newFeed = await this.resolveResponse(err, latestCommentFeed);
                                            comments.push(...newFeed.data);
                                            latestCommentFeed = newFeed;
                                        }
                                        comments.forEach(comment => {
                                            FacebookComment.upsert({
                                                id: comment.id,
                                                message: comment.message,
                                                lang: franc(comment.message),
                                                FBPostId: dbPost.id,
                                            })
                                        })
                                    })
                                })
                            });
                        });
                    })
                }
            })
        });
    }


    /**
     * @function resolveResponse
     * @param  {Object} err Error object
     * @param  {Object} res Response object
     * @description Resolves a response from the Facebook Graph API. Useful for resolving the pagination inside the response objects.
     * @memberof FacebookCrawler
     * @return {Promise} Promise, when the new result is fetched
     */
    resolveResponse(err, res) {
        return new Promise((resolve, reject) => {
            graph.get(res.paging.next, (err, res) => {
                if (err) return reject(err);
                resolve(res);
            })
        })
    }
}