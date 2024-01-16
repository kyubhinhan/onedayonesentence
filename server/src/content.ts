import express, { Express, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client'

const router = express.Router()
const prisma = new PrismaClient()

// create
router.post('/', async function (req, res) {
    const { title, author, date, impression } = req.body;

    if (!title || !author || !date || !impression) {
        res.status(400).send('param error')
        return
    }

    const newContent = await prisma.content.create({
        data: {
            title,
            author,
            date,
            impression,
        },
    });

    res.status(200).send('ok');
});

// get
router.get('/', async function (req, res) {
    const { dt } = req.query

    console.log(dt);

    if (!dt) {
        res.status(400).send('param error')
        return
    }

    const startDt = new Date(Number(dt))
    startDt.setDate(1)
    startDt.setHours(0, 0, 0, 1)

    const content = await prisma.content.findMany({
        where: {
            AND: [
                {
                    date: {
                        gte: startDt.getTime()
                    }
                },
                {
                    date: {
                        lte: Number(dt)
                    }
                }
            ]
        }
    })

    console.log(content)

    res.send(content.map((item) => ({ ...item, date: Number(item.date) })).sort((a, b) => b.date - a.date));
});

// update
router.put('/', async function (req, res) {
    const { id, title, author, dt, impression } = req.body;

    if (!id || !title || !author || !dt || !impression) {
        res.status(400).send('param error')
        return
    }

    const targetContent = await prisma.content.findUnique({
        where: {
            id: Number(id)
        }
    })

    if (!targetContent) {
        res.status(400).send('해당하는 대상을 찾을 수 없습니다.')
        return
    }

    const content = await prisma.content.update({
        where: {
            id: Number(id)
        },
        data: {
            title,
            author,
            date: dt,
            impression,
        }
    })

    res.send('ok');
});

// delete
router.delete('/', async function (req, res) {
    const { id } = req.query

    const content = await prisma.content.delete({
        where: {
            id: Number(id)
        }
    })

    res.send('ok');
});

export default router