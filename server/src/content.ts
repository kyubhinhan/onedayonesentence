import express, { Express, Request, Response } from 'express';
import { UserRequset } from '../src/index';
import CustomPrismaClient from './prisma';

const router = express.Router()

// create
router.post('/', async function (req: UserRequset, res) {
    const { title, author, date, impression } = req.body;

    if (!title || !author || !date || !impression) {
        res.status(400).send('param error')
        return
    }

    if (!req.userId) {
        res.status(401).send('cannot find userId')
        return
    }

    const newContent = await CustomPrismaClient.getInstance().content.create({
        data: {
            title,
            author,
            date,
            impression,
            userId: Number(req.userId)
        },
    });

    res.status(200).send('ok');
});

// get
router.get('/', async function (req: UserRequset, res) {
    const { dt } = req.query

    if (!dt) {
        res.status(400).send('param error')
        return
    }

    if (!req.userId) {
        res.status(401).send('cannot find userId')
        return
    }

    const inputDt = new Date(Number(dt))
    const startDt = new Date(inputDt.getFullYear(), inputDt.getMonth(), 1)
    const endDt = new Date(inputDt.getFullYear(), inputDt.getMonth() + 1, 0, 23, 59, 59, 999)

    const content = await CustomPrismaClient.getInstance().content.findMany({
        where: {
            AND: [
                {
                    userId: Number(req.userId)
                },
                {
                    date: {
                        gte: startDt.getTime()
                    }
                },
                {
                    date: {
                        lte: endDt.getTime()
                    }
                }
            ]
        }
    })

    res.send(content.map((item) => ({ ...item, date: Number(item.date), userId: Number(item.userId) })).sort((a, b) => b.date - a.date));
});

// update
router.put('/', async function (req: UserRequset, res) {
    const { id, title, author, date, impression } = req.body;

    if (!id || !title || !author || !date || !impression) {
        res.status(400).send('param error')
        return
    }

    if (!req.userId) {
        res.status(401).send('cannot find userId')
        return
    }

    const targetContent = await CustomPrismaClient.getInstance().content.findUnique({
        where: {
            id: Number(id)
        }
    })

    if (!targetContent) {
        res.status(400).send('해당하는 대상을 찾을 수 없습니다.')
        return
    }

    const content = await CustomPrismaClient.getInstance().content.update({
        where: {
            id: Number(id)
        },
        data: {
            id: Number(id),
            title,
            author,
            date: Number(date),
            impression,
            userId: Number(req.userId)
        }
    })

    res.send('ok');
});

// delete
router.delete('/', async function (req, res) {
    const { id } = req.query

    const content = await CustomPrismaClient.getInstance().content.delete({
        where: {
            id: Number(id)
        }
    })

    res.send('ok');
});

export default router